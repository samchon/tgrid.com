# SWOT Analysis
<!-- @templates([
    ["chapter", "1"],
    ["assets", "../../assets/"],
    ["blockchain.md", "blockchain.md"],
    ["examples.md", "../tutorial/examples.md"],
    ["Grid Computing", "[Grid Computing](../tutorial/concepts.md#11-grid-computing)"],
    ["Remote Function Call", "[Remote Function Call](../tutorial/concepts.md#12-remote-function-call)"],
    ["TSTL", "[TSTL](https://github.com/samchon/tstl)"]
]) -->
<!-- @import("internal/strengths.md") -->




## 2. Weaknesses
### 2.1. High Traffic
University in network system means the overhead, increase of traffic.

> But ignore the traffic. It's vulnerable in nowadays.

**TGrid** has invented ${{ Remote Function Call }} to come true the ${{ Grid Computing }}, so we are enjoyings the [1. Strengths](#1-strengths). However, if there is light, there also be the darkness. To accomplish the ${{ Remote Function Call }}, the data structure used by [Communicator](../tutorial/concepts.md#21-communicator) is JSON-string, who has not only high university but also high traffic.

```typescript
export type Invoke = IFunction | IReturn;

export interface IFunction
{
    uid: number;
    listener: string;
    parameters: IParamter[];
}
export interface IParameter
{
    type: string;
    value: any;
}

export interface IReturn
{
    uid: number;
    success: boolean;
    value: any;
}
```

The most standard way to reduce data transfer in network communication is to design special data structure and use it. By designing and applying optimal and special binary structures for each feature who uses network communication, it's possible to reduce amount of data transmission dramatically. In the example below, the binary structure uses 28 bytes per a record, and general data (JSON-string) uses about 100 to 200 bytes.

{% codegroup %}
```c::Binary-structure
struct candle
{
    long long date;
    unsigned int open;
    unsigned int close;
    unsigned int high;
    unsigned int low;
    unsigned int volume;
};
```
```json::JSON-string
{
    "date": "2019-01-05",
    "open": 300000,
    "close": 350000,
    "high": 370000,
    "close": 290000,
    "volume": 795041
}
```
{% endcodegroup %}

However, I think so. Traffic means nothing in nowadays.

Today's network communication technology has evolved from day to day, with the ability to transfer data in GB per a second. Design and utilize special binary structures for every features to reduce amount of data transmission... Well, I don't know if it was the past who can send data only KB per a second, should we do such vulnerable optimizations in nowadays?

If me, I would just endure the traffic problem and enjoy the [1. Strengths](#1-strengths).

### 2.2. Low Performance
**TGrid** based on script language and it makes performance to be low.

> But I've prepared the alternative solutions
> 
>   - Nonetheless, [1. Strengths](#1-strengths) are stronger.
>   - Infrastructure costs can be resolved by [3.2. Public Grid](#32-public-grid).
>   - Low performance can be resolved by partial optimization.
>   - Even if you should migrate to native language later, develop with **TGrid** first to make it faster and safer.

#### 2.2.1. Script Language
The full name of Tgrid is the TypeScript Grid Computing Framework, which is based on the TypeScript. And compilation result of the TypeScript is the JavaScript file, which is obviously a script language. Also, all of the programmers may know that, script language is slower than native language. Thus, ${{ Grid Computing }} system made with **TGrid** is slower than that made with native.

So we should consider something when creating the ${{ Grid Computing }} system, whether [1. Strengths](#1-strengths) of the **TGrid** can offset the disadvantage *Low Performance* caused by the script language.

Of course, if there's not the *performance* issue in your network system, or if you are tending to implement the ${{ Grid Computing }} system not to distribute great operations but only by business logic like blockchain, you don't need to worry anything. Just close your eyes and select the **TGrid** and ${{ Remote Function Call }}.

![seesaw](../../assets/images/appendix/seesaw.gif)

#### 2.2.2. Partial Optimization
On the other hand, I never have given up the *Low Performance* issue without any alternative solution. The increasing infrastructure costs by *Low Performance* can be resolved by the [3.2. Public Grid](#32-public-grid).  I'll benchmark it laster, but in my suggestion, the costs may not only be just resolved but also be decreased dramatically.

Also, there is another way to solve the *Low Performance* issue. Performance tuning starts from where the expected improvement is greatest. You don't have write all the program codes in C++. Write most of the program codes in TypeScript and implement with native language somewhere operations are concentrated (In NodeJS, interact with C++ directly and in Web Borwser, use Web Assembly).

{% panel style="info", title="TypeScript Standard Template Library" %}

${{ TSTL }} is an implementation of STL (Standard Template Library), defined by the C++ Standard Committee, in the *TypeScript*. If you develop a program with the ${{ TGrid }}, it means that you're using the same data structures and interfaces with the C++ standard library. Therefore, programs written in the ${{ TSTL }} are as easy to migrate to the C++.

Do you think there would be a performance issue in your pgrogram? So is there a possibility of migrating to the C++ later? If so, use ${{ TSTL }} without any hestitation. ${{ TSTL }} would give you an amazing experience.

{% endpanel %}

#### 2.2.3. Full Migration
Although you want to make the entire *Grid Computing* system in C++. I still recommend you to use the **TGrid** and ${{ TSTL }}. I'm not saying you "The *Low Performance* issue is nothing when comparing with [1. Strengths](#1-strengths). Even the *Low Performance* issue can be resolved by [2.2.2. Partial Optimization](#222-partial-optimization), so ignore the issue".

Desining and implementing a *Grid Computing* system, with native language like C++, from the beginning is extremely difficult. Not only it is difficult to develop, but it is also impossible to guarantee stability and the development terms would be infinitely long. If what you're trying to make is for distributing extra-large computations, the difficulty level of development would uprise even rather than the [Blockchain System, Steps to the Hell](blockchain.md#steps-to-hell).

So I recommend you. First, develop quickly and safely through the **TGrid** and ${{ Remote Function Call }}. At next, proceed your service quickly with focusing on the *Business Logic*. After confirming that the service is running stable, go ahead and proceed with the *Full Migration*. As there already has been the stable system, you just need to migrate them to C++ considering syntax.

In my experience, when developing a *Grid Computing* system in a native language, it was much efficient to using the migration strategy I've mentioned. The development terms was much shorter and system was much safer. 

Meanwhile, it's also possible to build a ${{ Grid Computing }} system with **TGrid** first and understand something later; the *Full Migration* was not required at all, no performance issue or the issue can resolved by [2.2.2. Partial Optimization](#222-partial-optimization). In such case, should we sigh and say "We were so lucky"?

### 2.3. Low Background
**TGrid** is a young project, so its background is shallow.

> I'll try my best to overcome it. Please support me a lot.

TGRid is a new framework just created. So no matter how plausible and roundbreaking the ${{ Remote Function Call }} is, number of projects using the **TGrid** is extremely small. Except for [demo projects](../tutorial/projects) of tutorial or commercial projects that I've made, the number would be much smaller. Thus, there are not enough commnities that can share informations and knowhows about the **TGrid**.

The [blockchain](#31-block-chain) project as an example, how can the blockchain can be easily developed by the **TGrid**, but havent't most of the blockchain projects been developed by the traditional method? It's hard to determine whether blockchain development using the ${{ Remote Function Call }} is easier than referencing legacy projects built by traditional method or not.

> But if you are building a blockchain project with a new kin of business logic, I condidently recommend you that **TGrid** is much easier.

It's the well known truth that **TGrid** is a new borned project and it has shallow background in today. I feel sad but there's no amazing way resolve the problem. The only way to reolsve it is to keep trying best for a long time. I believe that the ${{ Remote Function Call }} would soon be the new trend of network system development. I believe that this is the future and would keep the development, so please help me a lot.

In someday, **TGrid** will become famous. Maybe it doesn't take long.




<!-- @templates([
    ["market.md", "../tutorial/projects/market.md"]
]) -->
<!-- @import("internal/opportunities.md") -->




## 4. Threats
What can threat the **TGrid** ${{ Remote Function Call }}? Writing the *Swot Analysis*, I don't have any idea yet. If you have any idea, please inform me.

  - https://github.com/samchon/tgrid/issues