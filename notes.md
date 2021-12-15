# Further notes

## Install Wordpress directly with terraform (without seperate scripts)
+ Everything in terraform
+ Wordpress can be seperatly destroyed with terraform
- dependence on Kubernetes or Helm Plugins

```yaml
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "my-context"
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "my-first-namespace"
  }
}
```

## Further task: Automation via CI
- Input proposed MySQL passsword via Secrets (e.g. on GitHub)
- Create an Action for:
    - Creation of Cluster & Database
    - Installation of all Requirements
    - Installation of Wordpress itself
- Advanced:
    - Clone everything to a different zone, using forks
