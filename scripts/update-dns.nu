#!/usr/bin/env nu

module k8s {
  export def wait-load-balancer [name: string, namespace: string] {
    let ingress = (
      kubectl get service $name -n $namespace -o json
        | from json
        | get status.loadBalancer.ingress
    )
    if ($ingress | is-empty) { sleep 5sec; wait-load-balancer $name $namespace } else {}
  }

  export def get-ingress-ip [name: string, namespace: string] {
    kubectl get service $name -n $namespace -o json
      | from json
      | get status.loadBalancer.ingress
      | where not ip starts-with "10."
  }
}

module porkbun {
  export def delete_dns [
    api_key: string,
    secret_key: string,
    url: string,
    hostname: string,
    type: string
  ] {
    let delete_url = $"($url)/deleteByNameType/($hostname)/($type)"
    let response = (
      post -t application/json $delete_url {
        apikey: $api_key,
        secretapikey: $secret_key,
      }
    )
    $response
      | if is-empty {"OK"} else {$in}
  }

  export def create_dns [
    api_key: string,
    secret_key: string,
    url: string,
    hostname: string,
    ip: string,
    type: string
  ] {
    let create_url = $"($url)/create/($hostname)"
    let response = (
      post -t application/json $create_url {
        apikey: $api_key,
        secretapikey: $secret_key,
        content: $ip,
        type: $type,
      }
    )
    $response
      | if is-empty {"OK"} else {$in}
  }
}

def main [secret_file: string, hostname: string] {
  use k8s *
  use porkbun *

  wait-load-balancer "gateway" "ingress"
  let ip = get-ingress-ip "gateway" "ingress"

  let max_len_ipv4 = 16
  let type = (
    $ip
      | each { |it| if ($it.ip | str length) < $max_len_ipv4 {"A"} else {"AAAA"} }
      | wrap "type"
  )
  let ip = ($ip | merge $type)

  let api_key = (sops --decrypt --extract '["porkbun"]["apiKey"]' $secret_file)
  let secret_key = (sops --decrypt --extract '["porkbun"]["secretKey"]' $secret_file)
  let url = "https://porkbun.com/api/json/v3/dns"
  let delete_resp = (
    $ip
      | each { |it| delete_dns $api_key $secret_key $url $hostname $it.type }
      | wrap "delete-response"
  )
  let create_resp = (
    $ip
      | each { |it| create_dns $api_key $secret_key $url $hostname $it.ip $it.type }
      | wrap "create-response"
  )

  $ip
    | merge $delete_resp
    | merge $create_resp
}
