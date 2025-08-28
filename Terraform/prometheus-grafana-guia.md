# Guia de Instalação: Prometheus e Grafana no EKS com Helm

Este guia detalha o processo de instalação da stack de monitoramento `kube-prometheus-stack`, que inclui Prometheus, Grafana e outros componentes essenciais, em seu cluster EKS. Usaremos o Helm, o gerenciador de pacotes para Kubernetes, que é o método recomendado pela comunidade.

---

## Pré-requisitos

1.  **`kubectl` Configurado:** Seu `kubectl` deve estar configurado para se comunicar com seu cluster EKS. (Já fizemos isso nos passos anteriores).

2.  **Helm v3+ Instalado:** O Helm é necessário para instalar os pacotes. Se você não o tiver, pode instalá-lo seguindo o [guia oficial de instalação do Helm](https://helm.sh/docs/intro/install/).

---

## Passo 1: Adicionar o Repositório de Charts do Prometheus

O Helm funciona com repositórios, que são como catálogos de softwares. Precisamos adicionar o repositório da comunidade Prometheus, que contém o `kube-prometheus-stack`.

**1. Adicione o repositório:**
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

**2. Atualize a lista de charts para buscar as versões mais recentes:**
```bash
helm repo update
```

---

## Passo 2: Criar um Namespace para o Monitoramento

É uma boa prática de organização e segurança instalar ferramentas de monitoramento em seu próprio "espaço" isolado dentro do cluster, chamado de Namespace.

**Crie o namespace `monitoring`:**
```bash
kubectl create namespace monitoring
```

---

## Passo 3: Instalar a Stack Prometheus & Grafana

Agora, vamos usar o Helm para instalar o `kube-prometheus-stack` no namespace `monitoring`. Este comando irá baixar e configurar dezenas de recursos Kubernetes automaticamente (Prometheus, Grafana, Alertmanager, Node Exporters, etc.).

**Execute o comando de instalação:**
```bash
helm install prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring
```
*   `prometheus-stack` é o nome que estamos dando para a nossa instalação (release).
*   Pode levar alguns minutos para que todos os componentes sejam baixados e iniciados.

---

## Passo 4: Verificar a Instalação

Após a conclusão do comando anterior, vamos verificar se todos os componentes da stack estão rodando corretamente.

**Liste todos os recursos no namespace `monitoring`:**
```bash
kubectl get all -n monitoring
```

Você deverá ver uma lista de `pods`, `services`, `deployments`, `statefulsets`, e `daemonsets`. Verifique se os pods principais estão com o status `Running` ou `Completed`. Os mais importantes são:
*   `prometheus-stack-grafana-...` (o pod do Grafana)
*   `prometheus-prometheus-stack-prometheus-0` (o pod principal do Prometheus)
*   `prometheus-stack-kube-state-metrics-...`
*   `prometheus-stack-prometheus-node-exporter-...` (um pod para cada nó do seu cluster)

---

## Passo 5: Acessar o Dashboard do Grafana

Por padrão, o Grafana não é exposto publicamente na internet por questões de segurança. A maneira mais fácil e segura de acessá-lo é usando o recurso `port-forward` do `kubectl`, que cria um túnel de rede seguro entre sua máquina e o cluster.

**1. Inicie o Port-Forward para o Grafana:**
Abra um **novo terminal** (deixe este terminal aberto enquanto estiver usando o Grafana) e execute o comando:
```bash
kubectl port-forward svc/prometheus-stack-grafana 3000:80 -n monitoring
```
*   Isso redirecionará a porta `3000` da sua máquina local para a porta `80` do serviço Grafana dentro do cluster.

**2. Obtenha a Senha de Administrador:**
O nome de usuário padrão é `admin`. A senha inicial é gerada aleatoriamente e armazenada em um "Secret" do Kubernetes. Para obtê-la, execute este comando no seu terminal principal:
```bash
kubectl get secret prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

**3. Acesse e Faça Login:**
*   Abra seu navegador e acesse: [**http://localhost:3000**](http://localhost:3000)
*   **Usuário:** `admin`
*   **Senha:** Cole a senha que você obteve no comando anterior.

Pronto! Você está no Grafana. Ele já vem com uma fonte de dados (datasource) para o Prometheus e vários dashboards pré-configurados. Explore o menu "Dashboards" para ver a saúde do seu cluster.

---

## Passo 6: Acessar a Interface do Prometheus (Opcional)

Você também pode acessar a interface nativa do Prometheus para fazer consultas e ver o status dos alvos que ele está monitorando. O processo é o mesmo: `port-forward`.

**1. Inicie o Port-Forward para o Prometheus:**
Em um novo terminal, execute:
```bash
kubectl port-forward svc/prometheus-operated 9090:9090 -n monitoring
```
*   `prometheus-operated` é o nome do serviço que aponta para o pod do Prometheus.

**2. Acesse no Navegador:**
*   Abra seu navegador e acesse: [**http://localhost:9090**](http://localhost:9090)

Você verá a interface do Prometheus, onde pode executar consultas usando a linguagem PromQL.
