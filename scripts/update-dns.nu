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
  def delete_dns [
    url: string,
    hostname: string,
    subdomain: string,
    type: string
    api_key: string,
    secret_key: string,
  ] {
    let delete_url = $"($url)/deleteByNameType/($hostname)/($type)/($subdomain)"
    let response = (
      post -t application/json $delete_url {
        apikey: $api_key,
        secretapikey: $secret_key,
      }
    )
    $response
      | if is-empty {"OK"} else {$in}
  }

  def create_dns [
    url: string,
    hostname: string,
    subdomain: string,
    ip: string,
    type: string
    api_key: string,
    secret_key: string,
  ] {
    let create_url = $"($url)/create/($hostname)"
    let response = (
      post -t application/json $create_url {
        name: $subdomain,
        content: $ip,
        type: $type,
        apikey: $api_key,
        secretapikey: $secret_key,
      }
    )
    $response
      | if is-empty {"OK"} else {$in}
  }

  export def get_record_type [ip: table] {
    let max_len_ipv4 = 16
    $ip
      | each { |it| if ($it.ip | str length) < $max_len_ipv4 {"A"} else {"AAAA"} }
      | wrap "type"
  }

  export def update_dns [
    hostname: string,
    subdomains: list,
    ip: table,
    api_key: string,
    secret_key: string,
  ] {
    let url = "https://porkbun.com/api/json/v3/dns"
    $subdomains | each { |sub|
      let delete_resp = (
        $ip
          | each { |it| delete_dns $url $hostname $sub $it.type $api_key $secret_key }
          | wrap "delete-response"
      )
      let create_resp = (
        $ip
          | each { |it| create_dns $url $hostname $sub $it.ip $it.type $api_key $secret_key }
          | wrap "create-response"
      )

      $ip
        | insert "sub" $sub
        | merge $delete_resp
        | merge $create_resp
      } | flatten
    }
}

def main [secret_file: string, hostname: string] {
  use k8s *
  use porkbun *

  wait-load-balancer "gateway" "ingress"
  let ip = get-ingress-ip "gateway" "ingress"

  let type = get_record_type $ip
  let ip = ($ip | merge $type)

  let subdomains = ["", "*"]
  let api_key = (sops --decrypt --extract '["porkbun"]["apiKey"]' $secret_file)
  let secret_key = (sops --decrypt --extract '["porkbun"]["secretKey"]' $secret_file)
  update_dns $hostname $subdomains $ip $api_key $secret_key
}
