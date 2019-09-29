<!-- @templates([
    ["Grid Computing", "[Grid Computing](../tutorial/concepts.md#11-grid-computing)"],
    ["Remote Function Call", "[Remote Function Call](../tutorial/concepts.md#12-remote-function-call)"]
    ["Network System", "#2-network-system"],
    ["Business Logic", #3-business-logic"]
]) -->

# Blockchain
## 1. Outline
With **TGrid** and ${{ Remote Function Call }}, you can implement blockchain much easily.

It's a famous story that difficulty of developing blockchain is very high. Not only because of the high wages of the blockchain developers, but also from a technical point of view, blockchain is actually very difficult to implement. But, if you ask me what is such difficult, I will answer:

The difficulty comes from the ${{ Network System }}, not ${{ Business Logic }}.




## 2. Network System
The real challenge to implementing blockchain comes from the distributed processing system using network communication.

The *Network System* used in blockchain is a type of great distributed processing system, conostructed by millions of computers interacting with network communication. The great distributed processing systems like the blockchain always present us the tremendous difficulties. The word 'perfect' is inserted on every development processes

The requirements must be analyzed perfectly, use-cases must be identified perfectly, data and network architectures must be designed, perfectly and mutual interaction test must be perfectly, etc.

<a id="steps-to-hell"></a>

{% panel style="info", title="Steps to Hell" %}

#### 1 Requirements
To develop a Blockchain in the traditional way, you've to hire an excellent architect.

First of all, this architect collects and documets all of the requirements about the Blockchain to be newly created. If failed to discover some requirements or if some requirements are changed later, you've to restart all the processes. Thus, discovering requirements must very meticulous and detail.

#### 2 Analyses
Analyze collected requirements and discover all of the use cases perfectly. After determining these use cases, design a Conceptual Architecture. If any contraction or error was found on the collected requirements, turn back to the [1 Requirements](#1-requirements) and start everything again.

#### 3 Designs
After Conceptual Architecture, design below architectures continuously.

 - Data Architecture
 - Network Architecture
 - Software Architecture

The first thing to design is the Data Architecture. It means to design the Data Model that the new Blockchain project would use. The Data Models is correspond to the 'Block'. If you've mis-designed the Data Architecture, you've retreat to current step and design it again. The step where you are, it's not a matter, so try to be sure the design it perfectly

The second is Network Architecture, where the design of Network Distribution is done. At first, grant each role to every computers in the Distributed Processing System. After that, define all of the network communications between participated computers. This Network Architecture may be the most difficult stage in the development processes. Also, the Network Architecture must be more perfact than any other architectures.

  - Define every moment of network transmissions and receptions
  - Define every network messages (maybe binary structure)
  - Define implications of each network message means (commands to be executed, etc.)

The last is Software Architecture for individual programs running on each computer. Refering Data Architecture and Network Architecture, you'll design the Software Architectures representing what each program should implement.

#### 4 Implementations
This is the process implementing software programs for each computer participated in the Distributed Processing System. The implementation would reference pre-designed architectures. If you any error of Architecture Design was found on the implementation process, you've to retreat to the step and retart all the processes again.

If the error was caused by Requirements or Business Model...

#### 5 Conservations
It's the last stage verifying the designs and implementations are perfect.

Of course, if there are any omissionss or contradctions in the development process, you have to retreat and restart the process from the beginning. For example, if the Data Architecture is invalid, the majority of the Network Architecture must be destroyed and redesigned, resulting in Software Architecture and Program Code being affected.

On the contrary, if the verification process confirms that all development is completed, then the Blockchain system can be operated.

{% endpanel %}

As you can see, it's termendous difficult to develop the blockchain project who needs to prepare the great distributed processing system. Because of such terrible difficulty, when developing a blockchain project, you've hire the excellent architects and developers who are in the genius level. 

However, even those crazy architects and genius developers cannot assure the success. Even they can be fallen into the swamp due to incomplete requirement analyses or mistakes on architecture designs. I think those crazy difficulties may be a reason why many people and companies, who had made loud noises developing Blockchain, are quite in nowadays.




## 3. Business Logic
On contrary, *Business Logic* of the blockchain is not such difficult. 

Core elements of the blockchain are, as the name suggest, the first is 'Block' and the second is 'Chain'. The 'Block' is about defining and storing data and the 'Chain' is about policy that how to reach to an agreement when writing data to the 'Block'.

 Component | Conception     | Description
-----------|----------------|---------------------------------------
 Block     | Data Structure | Way to defining and storing data
 Chain     | Requirements   | A policy for reaching to an agreement

Let's assume that you are developing the 'Block' and 'Chain' as a program running only on a single computer. In this case, you just need to design the data structure and implement code storing the data on disk. Also, you would analyze the requirements (policy) and implement them. Those skills are just the essentials for programmers. 

In other word, *Business Logic* of blockchain is something that any skilled programmers can implement.

  - To develop the *Block* and *Chain*:
    - Ability to design Data Structure
    - Ability to store Data on Device
    - Ability to analyze policy (requirements)
    - Ability to implement them




## 4. Conclusion
Reading the stories, it can be summarized as '${{ Business Logic }} of blockchain is easy, however composing its ${{ Network System }} is extremely difficult'.

Do you remember? With **TGrid** and ${{ Remote Function Call }}, you can come true the true ${{ Grid Computing }}. Many computers interacting with network communication are replaced by only <u>one virtual computer</u>. Even ${{ Business Logic }} code of the virtual computer is same with another ${{ Business Logic }} code running on a single physical computer.

  - ${{ Business Logic }} of blockchain is not so difficult.
  - With **TGrid**, you can concentrate only on the ${{ Business Logic }}.
  - So with **TGrid**, you can easily implement the blockchain.

Thus, if you adapt the **TGrid** and ${{ Remote Function Call }}, difficulty of the blockchain development would be dropped to the level of ${{ Business Logic }} rather than ${{ Network System }}. Forget complex ${{ Network System }} and just focus on the essence of what you want to develop; the ${{ Business Logic }.