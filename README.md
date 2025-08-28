# Projeto de Infraestrutura EKS com Foco em Observabilidade

Este projeto provisiona um cluster Amazon EKS (Elastic Kubernetes Service) completo e robusto na AWS utilizando Terraform. O principal diferencial é a configuração automática de dashboards de monitoramento detalhados no Amazon CloudWatch, fornecendo uma visão clara da saúde e performance do cluster desde o primeiro momento.

## Funcionalidades Principais

- **Provisionamento Automatizado com IaC:** Toda a infraestrutura (VPC, Subnets, NAT Gateways, Cluster EKS, Node Groups) é criada e gerenciada como código com Terraform, garantindo consistência e reprodutibilidade.
- **Arquitetura de VPC Segura:** Cria uma VPC com sub-redes públicas e privadas distribuídas em 3 zonas de disponibilidade para alta resiliência.
- **Cluster EKS Otimizado:** Implanta um cluster EKS com um grupo de nós gerenciados (Managed Node Group), facilitando a operação e atualização.
- **Backend Terraform Remoto:** Configura um bucket S3 e uma tabela DynamoDB para armazenar o estado do Terraform (`tfstate`) de forma segura e centralizada, permitindo o trabalho em equipe.
- **Observabilidade com CloudWatch Container Insights:** O Add-on do CloudWatch é instalado e configurado automaticamente, coletando métricas detalhadas, logs e dados de performance de todos os níveis do cluster (nós, pods, containers).
- **Dashboards Pré-Configurados:** Cria múltiplos dashboards no CloudWatch para diferentes públicos:
    - **Dashboard Executivo:** Visão macro com os principais KPIs de saúde do cluster.
    - **Dashboard Avançado:** Análise detalhada de performance do control plane, worker nodes e workloads.
    - **Dashboard de Debug:** Focado em métricas específicas para resolução de problemas.
- **Guia de Monitoramento Alternativo:** Inclui um guia (`prometheus-grafana-guia.md`) para instalar e configurar a stack Prometheus & Grafana como uma solução de monitoramento alternativa.
- **Aplicação de Exemplo:** Fornece um manifesto (`nginx-deployment.yaml`) para implantar uma aplicação Nginx e gerar tráfego, permitindo a visualização imediata dos dashboards em ação.

## Arquitetura

A infraestrutura consiste nos seguintes componentes:

1.  **VPC:** Uma Virtual Private Cloud isolada para hospedar todos os recursos.
2.  **Sub-redes:**
    - **Públicas:** Onde os Load Balancers são provisionados.
    - **Privadas:** Onde os Worker Nodes (instâncias EC2) do EKS são executados para maior segurança.
3.  **NAT Gateway:** Permite que os recursos nas sub-redes privadas acessem a internet (para baixar imagens de container, etc.) sem serem expostos diretamente.
4.  **EKS Control Plane:** A camada de gerenciamento do Kubernetes, mantida pela AWS.
5.  **EKS Managed Node Group:** Um grupo de instâncias EC2 que servem como os "trabalhadores" do cluster, onde os pods das aplicações são executados.
6.  **CloudWatch:**
    - **Logs:** Centraliza os logs do control plane e das aplicações.
    - **Metrics (Container Insights):** Coleta e armazena métricas de performance.
    - **Dashboards:** Visualiza as métricas coletadas em gráficos e painéis informativos.

## Pré-requisitos

Antes de começar, garanta que você tenha as seguintes ferramentas instaladas e configuradas:

-   **AWS CLI:** Autenticada com uma conta AWS com as permissões necessárias.
-   **Terraform:** Versão 1.6.0 ou superior.
-   **kubectl:** Para interagir com o cluster Kubernetes.
-   **Helm:** (Opcional) Necessário apenas se você for seguir o guia de instalação do Prometheus/Grafana.

## Como Implantar a Infraestrutura

Siga os passos abaixo a partir do diretório `Terraform/`:

1.  **Configurar o Backend:**
    O Terraform precisa de um local para armazenar seu arquivo de estado. Execute o script fornecido para criar o bucket S3 e a tabela DynamoDB.
    ```bash
    bash BucketS3-TfState.sh
    ```

2.  **Inicializar o Terraform:**
    Este comando baixa os módulos e provedores necessários.
    ```bash
    terraform init -upgrade
    ```

3.  **Planejar a Implantação:**
    O Terraform irá analisar o código e criar um plano de execução, mostrando todos os recursos que serão criados.
    ```bash
    terraform plan -out plan.out
    ```

4.  **Aplicar o Plano:**
    Este comando executa o plano e cria todos os recursos na sua conta AWS. A criação do cluster EKS pode levar de 15 a 20 minutos.
    ```bash
    terraform apply "plan.out"
    ```

## Como Usar o Cluster e os Dashboards

1.  **Configurar o `kubectl`:**
    Após a criação do cluster, configure seu `kubectl` para se conectar a ele. O comando exato pode ser obtido no output do Terraform ou usando a AWS CLI:
    ```bash
    aws eks update-kubeconfig --region us-east-1 --name plataforma-bet-eks-cluster
    ```

2.  **Implantar a Aplicação de Teste:**
    Para gerar dados e testar os dashboards, implante o Nginx.
    ```bash
    kubectl apply -f ../k8s/nginx-deployment.yaml
    ```

3.  **Acessar os Dashboards do CloudWatch:**
    -   Vá para o serviço **CloudWatch** no Console da AWS.
    -   No menu à esquerda, clique em **Dashboards**.
    -   Você verá os dashboards criados (`EKS-Executive-Dashboard`, `EKS-Advanced-Dashboard`, etc.). Clique neles para explorar.
    -   **Nota:** Pode levar de 5 a 15 minutos para que os dados do Container Insights comecem a popular os gráficos.

4.  **Compartilhar os Dashboards:**
    -   Abra o dashboard desejado.
    -   Clique no menu **Ações** (Actions) -> **Compartilhar dashboard** (Share dashboard).
    -   Ative o compartilhamento público para gerar um link que pode ser visualizado por qualquer pessoa, sem necessidade de login na AWS.

## Limpeza

Para remover todos os recursos criados por este projeto e evitar custos, execute o seguinte comando no diretório `Terraform/`:

```bash
terraform destroy
```
