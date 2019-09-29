<!-- 
must define those templates

  - assets
  - blockchain.md
  - market.md
  - Grid Computing
  - Remote Function Call

-->

## 3. Opportunities
### 3.1. Blockchain
> Detailed Content: [**Appendix** > **Blockchain**](${{ blockchain.md }}})

With **TGrid**, you can develop *Blockchain* easily.

It's a famous story that difficulty of developing blockchain is very high. Not only because of the high wages of the blockchain developers, but also from a technical point of view, blockchain is actually very difficult to implement. But, if you ask me what is such difficult, I will answer that not Business Logic* but *Network System*.

The [Network System](${{ blockchain.md }}#2-network-system) used by blockchain is a type of great distributed processing system, conostructed by millions of computers interacting with network communication. The great distributed processing systems like the blockchain always present us the tremendous difficulties. The word 'perfect' is inserted on every development processes; requirements must be analyzed perfectly, use-cases must be identified perfectly, data and network architectures must be designed, perfectly and mutual interaction test must be perfectly.

On contrary, [Business Logic](${{ blockchain.md }}#3-business-logic) of the blockchain is not such difficult. Core elements of the blockchain are, as the name suggest, the first is 'Block' and the second is 'Chain'. The 'Block' is about defining and storing data and the 'Chain' is about policy that how to reach to an agreement when writing data to the 'Block'.

 Component | Conception     | Description
-----------|----------------|---------------------------------------
 Block     | Data Structure | Way to defining and storing data
 Chain     | Requirements   | A policy for reaching to an agreement

Let's assume that you are developing the 'Block' and 'Chain' as a program running only on a single computer. In this case, you just need to design the data structure and implement code storing the data on disk. Also, you would analyze the requirements (policy) and implement them. Those skills are just the essentials for programmers. In other word, [Business Logic](${{ blockchain.md }}#3-business-logic) of blockchain is something that any skilled programmers can implement.

  - To develop the *Block* and *Chain*:
    - Ability to design Data Structure
    - Ability to store Data on Device
    - Ability to analyze policy (requirements)
    - Ability to implement them

Do you remember? With **TGrid** and ${{ Remote Function Call }}, you can come true the true ${{ Grid Computing }}. Many computers interacting with network communication are replaced by only <u>one virtual computer</u>. Even [Business Logic](${{ blockchain.md }}#2-network-system) code of the virtual computer is same with another [Business Logic](${{ blockchain.md }}#2-network-system) code running on a single physical computer.

Thus, if you adapt the **TGrid** and ${{ Remote Function Call }}, difficulty of the blockchain development would be dropped to the level of [Business Logic](${{ blockchain.md }} rather than [Network System](${{ blockchain.md }}#2-network-system). Forget complex [Network System](${{ blockchain.md }}#2-network-system) and just focus on the essence of what you want to develop; the [Business Logic](${{ blockchain.md }}.

### 3.2. Public Grid
> Related Project: [**Tutorial** > **Projects** > **Grid Market**](${{ market.md }})

With **TGrid**, you can procure resources for ${{ Grid Computing }} from unspecified crowds, very easily and inexpensively.

When composing *traditional Grid Computing*, of course, many computers should be prepared. As the number of computers required increases, so does the infrastructure and costs associated with procuring them. Also, you've to install programs and configure settings for the network communication on the prepared computers. Such duties increase your efforts and let you to be tired. Is it so nature?

Name | Consumer                              | Supplier
-----|---------------------------------------|-------------------------------
Who  | Developer of ${{ Grid Computing }}    | Unspecified crowds connecting to the Internet
What | Consumes resources of the *Suppliers* | Provides resources to *Consumer*
How  | Deliver program code to *Suppliers*   | Connect to special URL by Internet Browser

However, TGrid even can economize such costs and efforts dramatically. You can procure resources for ${{ Grid Computing }} from the unspecified crowds. Those unspecified crowds do not need to prepare anything like installing some program or configuring some setting. The only need those unspecified crowds is just connecting to special URL by Internet Browser.

The program that each *Supplier* should run is provided by the *Consumer* as JavaScript code. Each *Supplier* would act its role by the JavaScript code. Of course, interactions with *Supplier* and *Consumer* (or with a third-party computer) would use the ${{ Remote Function Call }}, so they are just one virtual computer.

> Base language of the **TGrid** is *TypeScript* and compilation result of the TypeScript is the *JavaScript* file. As *JavaScript* is a type of script language, it can be executed dinamiccaly. Therefore, the *Supplier* can execute the program by script code delivered by the *Consumer*.

![Grid Market](${{ assets }}images/projects/market/actors.png)

[Grid Market](${{ market.md }}) is one of the most typical example case for the *Public Grid*, a demo project for tutorial learning. In this demo project, *Consumer* also procures resources from the *Suppliers* for composing the ${{ Grid Computing }} system. *Supplier* also provides its resources just by connecting to the special URL by Internet Browser, too. Of course, in the [Grid Market](${{ market.md }}), the program that *Supplier* would run still comes from the *Consumer*.

However, there's a special thing about the [Grid Market](${{ market.md }}), it is that there is a *cost* for the *Consumer* to procure the *Suppliers*' resources. Also, intermediary *Market* exists and it charges fee for mediation between the *Consumer* and *Supplier*.

  - `Market`: Intermediary market for the *Suppliers* and *Consumers*.
  - `Consumer`: Purchase resources from the *Suppliers.
  - `Supplier`: Sells its own resources to the *Consumer*.

### 3.3. Market Expansions
The ${{ Grid Computing }} market would be grown up day by day.

The future belongs to those who prepare. Prepare the future by **TGrid** and ${{ Remote Function Call }}. Also, I hope you to hold some changes from the future.