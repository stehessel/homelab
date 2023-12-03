bundle: {
	apiVersion: "v1alpha1"
	name:       "k3s"
	instances: {
		"k3s": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
			namespace: "flux-system"
			values: {
				git: {
					url:  "https://github.com/stehessel/homelab"
					ref:  "refs/heads/master"
					path: "./flux/clusters/k3s"
				}
				sync: targetNamespace: "flux-system"
			}
		}
	}
}
