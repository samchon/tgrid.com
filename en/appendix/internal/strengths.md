<!-- 
must define those templates

  - chapter
  - assets
  - blockchain.md
  - examples.md
  - Grid Computing
  - Remote Function Call

-->

## ${{ chapter }}. Strengths
### ${{ chapter }}.1. Easy Development
Anyone can easily make a network system.

It's difficult to make network system because many of computers are interacting together to accomplish a common task. Therefore, the word 'perfect' is inserted on every development processes; requirements must be analyzed perfectly, use-cases must be identified perfectly, data and network architectures must be designed, perfectly and mutual interaction test must be perfectly.

{% panel style="info", title="Something to Read" %}
[Blockchain's Network System, Steps to Hell](${{ blockchain.md }}#steps-to-hell)
{% endpanel %}

However, with TGrid and ${{ Remote Function Call }}, you can come true the true ${{ Grid Computing }}. Many computers interacting with network communication are replaced by only <u>one virtual computer</u>. Even *Business Logic* code of the virtual computer is same with another *Business Logic* code running on a single physical computer.

![Difficulty Level Graph](${{ assets }}/images/appendix/difficulty_level_graph.png)

Thus, you can make a network system very easily if you use the **TGrid**. Forget everything about the network; protocolcs and designing message structures, etc. You only concentrate on the *Business Logic*, the essence of what you want to make. Remeber that, as long as you use the TGrid, you're just making a single program running on a single (virtual) computer.

### ${{ chapter }}.2. Safe Implementation
By compilation and type checking, you can make network system safe.

When developing a distributed processing system with network communication, one of the most embarrassing thing for developers is the run-time error. Whether network messages are correctly constructed and exactly parsed, all can be detected at the run-time, not the compile-time.

Let's assume a situation; There's a distributed processing system build by traditional method and there's a critical error on the system. Also, the critical error wouldn't be detected until the service starts. How terrible it is? To avoid such terrible situation, should we make a test program validating all of the network messages and all of the related scenarios? If compilation and type checking was supported, everything would be simple and clear.

**TGrid** provides exact solution about this compilation issue. TGrid has invented ${{ Remote Function Call }} to come true the real ${{ Grid Computing }}. What the ${{ Remote Function Call }} is? Calling functions remotly, isn't it a function call itself? Naturally, the function call is protected by *TypeScript Compilter*, therefore guarantees the *Type Safety*.

Thus, with **TGrid** and ${{ Remote Function Call }}, you can adapt compilation and type checking on the network system. It helps you to develop a network system safely and conveniently. Let's close this chapter with an example of *Safey Implementation*.

```typescript
import { WebConnector } from "tgrid/protocols/web/WebConnector"
import { Driver } from "tgrid/components/Driver";

interface ICalculator
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;

    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;
    divides(x: number, y: 0): never;
}

async function main(): Promise<void>
{
    //----
    // CONNECTION
    //----
    let connector: WebConnector = new WebConnector();
    await connector.connect("ws://127.0.0.1:10101");

    //----
    // CALL REMOTE FUNCTIONS
    //----
    // GET DRIVER
    let calc: Driver<ICalculator> = connector.getDriver<ICalculator>();

    // CALL FUNCTIONS REMOTELY
    console.log("1 + 6 =", await calc.plus(1, 6));
    console.log("7 * 2 =", await calc.multiplies(7, 2));

    // WOULD BE COMPILE ERRORS
    console.log("1 ? 3", await calc.pliuowjhof(1, 3));
    console.log("1 - 'second'", await calc.minus(1, "second"));
    console.log("4 / 0", await calc.divides(4, 0));
}
main();
```

> ```bash
> $ tsc
> src/index.ts:33:37 - error TS2339: Property 'pliuowjhof' does not exist on type 'Driver<ICalculator>'.
> 
>     console.log("1 ? 3", await calc.pliuowjhof(1, 3));
> 
> src/index.ts:34:53 - error TS2345: Argument of type '"second"' is not assignable to parameter of type 'number'.
> 
>     console.log("1 - 'second'", await calc.minus(1, "second"));
> 
> src/index.ts:35:32 - error TS2349: Cannot invoke an expression whose type lacks a call signature. Type 'never' has no compatible call signatures.
> 
>     console.log("4 / 0", await calc.divides(4, 0));
> ```

### ${{ chapter }}.3. Network Refactoring
Critical changes on network systems can be resolved flexibly.

In most case of developing network distributed processing system, there can be an issue that, necessary to major change on the network system. In someday, neccessary to *refactoring* in network level would be come, like software refactoring.

The most representative of that is the *performance* issue. For an example, there is a task and you estimated that the task can be done by one computer. However, when you actually started the service, the computation was so large that one computer was not enough. Thus, you should distribute the task to multiple computers. On contrary, you prepared multiple computers for a task. However, when you actually started the service, the computation was so small that just one computer is sufficient for the task. Sometimes, assigning a computer is even excessive, so you might need to merge the task into another computer.

![Diagram of Composite Calculator](${{ assets }}images/examples/composite-calculator.png) | ![Diagram of Hierarchical Calculator](${{ assets }}images/examples/hierarchical-calculator.png)
:-------------------:|:-----------------------:
[Composite Calculator](${{ examples.md }}#22-remote-object-call) | [Hierarchical Calculator](${{ examples.md }}#23-object-oriented-network)

I'll explain this *Network Refactoring*, caused by performance issue, through an example case that is very simple and clear. In a distributed processing system, there was a computer that providing a calculator. However, when this system was actually started, amount of the computations was so enormous that the single computer couldn't afford the computations. Thus, decided to separate the computer to three computers.


  - [`scientific`](${{ examples.md }}#hierarchical-calculatorscientificts): scientific calculator server
  - [`statistics`](${{ examples.md }}#hierarchical-calculatorstatisticsts): statistics calculator server
  - [`calculator`](${{ examples.md }}#hierarchical-calculatorcalculatorts): mainframe server
    - four arithmetic operations are computed by itself
    - scientific and statistics operations are shifted to another computers
    - and intermediates the computation results to client

If you solve this *Network Refactoring* by traditional method, it would be a hardcore duty. At first, you've to design a message protocol used for neetwork communication between those three computers. At next, you would write parsers for the designed network messges and reprocess the events according to the newly defined network architecture. Finally, you've to also prepare the verifications for those developments.

> Things to be changed
>  - Network Architecture
>  - Message Protocol
>  - Event Handling
>  - *Business Logic* Code

However, if you use the **TGrid** and ${{ Remote Function Call }}, the issue can't be a problem. In the **TGrid**, each computer in the network system is just one object. Whether you implement the remote calculator in one computer or distribute operations to three computers, its *Business Logic* code must be the same, in always.

I also provide you the best example for this *performance* issue causing the *Network Refactoring*. The first demonstration code is an implementation of a single calculator server and the second demonstration code is an implementation of a system distributing operations to three servers. As you can see, although principle structure of network system has been changed, you don't need to worry about it if you're using the **TGrid** and ${{ Remote Function Call }}.

  - [Demonstration - Remote Object Call](${{ examples.md }}#22-remote-object-call)
  - [Demonstration - Object Oriented Network](${{ examples.md }}#23-object-oriented-network)