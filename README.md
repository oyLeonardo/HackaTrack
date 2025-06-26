<div align="center">

<img src="https://i.imgur.com/7tjl4gr.png" width="30%" alt="Project Logo"/>

# HACKATRACK

🎒 **Gestão Inteligente de Equipamentos - Projeto HackaTruck**

![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
![Arduino](https://img.shields.io/badge/-Arduino-00979D?style=for-the-badge&logo=Arduino&logoColor=white)
![Node-RED](https://img.shields.io/badge/Node--RED-%238F0000.svg?style=for-the-badge&logo=node-red&logoColor=white)
<img src="https://imgur.com/jioPKfX.png" alt="UNB Logo" height="28"/>

</div>

---

## 🚀 Sobre o Projeto

O HackaTrack surgiu a partir da vivência no programa **HackaTruck**, onde identificamos uma necessidade crítica: **a gestão eficiente dos equipamentos fornecidos aos alunos**, especialmente mochilas contendo **MacBooks**.

A ausência de um sistema robusto gerava:
- Dificuldade em monitorar/gerenciar os itens
- Risco de extravios
- Processos manuais demorados e propensos a erros

Nossa solução é um **aplicativo móvel inteligente**, desenvolvido para **otimizar a administração dos ativos do projeto**, proporcionando:
- Rastreabilidade completa
- Organização aprimorada
- Responsabilização clara

O objetivo é garantir que **cada item esteja onde precisa estar**, com agilidade e precisão.

---

## ✨ Tecnologias Utilizadas

A solução foi construída combinando tecnologias de desenvolvimento mobile, cloud e Internet das Coisas (IoT):

- **SwiftUI**: Para uma interface de usuário fluida, moderna e intuitiva em dispositivos iOS.
- **Node-RED**: Utilizado como ferramenta de integração e processamento de dados com fluxo visual.
- **IoT**: Fundamenta a comunicação entre os objetos físicos (equipamentos) e o sistema digital.

---

## 🔌 Componentes IoT

Para possibilitar o monitoramento/gerenciamento em tempo real e identificação única dos itens, utilizamos:

- **Arduino**: Plataforma base para controle dos sensores e leitura dos dados.
- **Módulo RFID**: Responsável pela leitura das **tags de identificação** dos itens.
- **RFID Tags**: Acopladas às mochilas e aos MacBooks, permitindo rastreamento único e seguro.

---

## 📦 Principais Funcionalidades

| Funcionalidade                         | Descrição                                                                 |
|----------------------------------------|---------------------------------------------------------------------------|
| 🎒 **Rastreamento de Equipamentos**   | Identificação e localização em tempo real de mochilas e MacBooks via RFID |
| 📲 **Aplicativo iOS**                 | Interface amigável para gerenciamento dos itens no ambiente mobile        |
| 📊 **Painel de Estatísticas**         | Exibição de dados como uso recente, status dos itens e alertas            |
| 🧭 **Histórico de Atividades**       | Registros de movimentações e alterações feitas nos equipamentos           |
| 🔔 **Sistema de Alertas**            | Notificações sobre itens fora do local, atrasos ou possíveis extravios    |
| ⚙️ **Configurações Personalizáveis** | Ajustes no modo escuro, preferências do usuário e logs do sistema         |
| 🔗 **Integração IoT**                | Comunicação entre o app, Node-RED e os sensores via Arduino               |
| 🧪 **Ambiente de Testes**            | Testes locais com mock de leitura RFID e simulações de inventário         |

---

## 🤝 Como Contribuir

Quer contribuir com o projeto? Siga os passos abaixo:

1. **Fork** este repositório
2. Crie sua branch:  
```bash
git checkout -b feature/SuaFeature
```
3. Faça o commit das suas alterações.
```bash
git commit -m 'Adiciona nova funcionalidade'
```
4. Faça o push para sua branch:
```
git push origin feature/SuaFeature
```
5. Abra um **PR** (Pull Request)


## 📄 Licença
Distribuído sob a Licença MIT. Veja o arquivo `LICENSE.md` para mais detalhes.

<div align="center">
🛠️ Feito com dedicação por estudantes da <strong>UnB</strong> no programa <strong>HackaTruck</strong>
</div>
