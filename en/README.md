<!-- @templates([
    [ "Grid Computing", "[Grid Computing](#12-grid-computing)" ],
    [ "Remote Function Call", "[Remote Function Call](#13-remote-function-call)" ]
]) -->

# TGrid
## 1. Introduction
### 1.1. Outline
![Slogan Flag](../assets/images/flag.png)

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/samchon/tgrid/blob/master/LICENSE)
[![npm version](https://badge.fury.io/js/tgrid.svg)](https://www.npmjs.com/package/tgrid)
[![Downloads](https://img.shields.io/npm/dm/tgrid.svg)](https://www.npmjs.com/package/tgrid)
[![Build Status](https://github.com/samchon/tgrid/workflows/build/badge.svg)](https://github.com/samchon/tgrid/actions?query=workflow%3Abuild)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fsamchon%2Ftgrid.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fsamchon%2Ftgrid?ref=badge_shield)
[![Chat on Gitter](https://badges.gitter.im/samchon/tgrid.svg)](https://gitter.im/samchon/tgrid?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Full name of **TGrid** is <u>TypeScript Grid Computing Framework</u>.

As its name suggests, **TGrid** is a useful framework for implementating ${{ Grid Computing }} in the TypeScript. With **TGrid** and its core concept ${{ Remote Function Call }}, you can make many computers to be <u>a virtual computer</u>.

To know more, refer below links. If you are the first comer to the **TGrid**, I strongly recommend you to read the [Guide Documents](https://tgrid.com). In article level, [Basic Concepts](https://tgrid.com/en/tutorial/concepts.html) and [Learn from Examples](https://tgrid.com/en/tutorial/examples.html) sections would be good choices.

  - Repositories
    - [GitHub Repository](https://github.com/samchon/tgrid)
    - [NPM Repository](https://www.npmjs.com/package/tgrid)
  - Documents
    - [API Documents](https://tgrid.com/api)
    - **Guide Documents**
      - [English](https://tgrid.com/en)
      - [한국어](https://tgrid.com/ko)
    - [Release Notes](https://github.com/samchon/tgrid/releases)




### 1.2. Grid Computing
![Grid Computing](../assets/images/concepts/grid-computing.png)

> Computers be a (virtual) computer

As its name suggests, **TGrid** is a useful framework for *Grid Computing*. However, perspective of *Grid Computing* in **TGrid** is something different. It doesn't mean just combining multiple computers uinsg network communication. **TGrid** insists the real *Grid Computing* must be possible to turning multiple computers into <u>a virtual computer</u>.

Therefore, within framework of the **TGrid**, it must be possible to develop *Grid Computing* System as if there has been only a computer from the beginning. A program running on a single computer and another program runninng on the Distributed Processing System with millions of computers, both of them must have <u>similar program code</u>. It's the real *Grid Computing*.

Do you agree with me?

### 1.3. Remote Function Call
**TGrid** realizes the true ${{ Grid Computing }} through *Remote Function Call*. It literally calling remote system's functions are possible. With the *Remote Function Call*, you can access to objects of remote system as if they have been in my memory from the beginning.

With **TGrid** and *Remote Function Call*, it's possible to handle remote system's objects and functions as if they're mine from the beginning. Do you think what that sentence means? Right, being able to call objects and functions of the remote system, it means that current and remote system are integrated into a <u>single virtual computer</u>.

However, whatever ${{ Grid Computing }} and *Remote Function Call* are, you've only heard theoretical stories. Now, it's time to see the real program code. Let's see the demonstration code and feel the *Remote Function Call*. If you want to know more about the below demonstration code, read a lesson [Learn from Examples](https://tgrid.com/en/tutorial/examples.html) wrote into the [Guide Documents](https://tgrid.com).

#### [`composite-calculator/server.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/composite-calculator/server.ts)
```typescript
import { WebServer, WebAcceptor } from "tgrid/protocols/web";
import { CompositeCalculator } from "../../providers/Calculator";

async function main(): Promise<void>
{
    let server: WebServer = new WebServer();
    await server.open(10102, async (acceptor: WebAcceptor) =>
    {
        await acceptor.accept(new CompositeCalculator());
    });
}
main();
```

#### [`composite-calculator/client.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/composite-calculator/client.ts)
```typescript
import { WebConnector } from "tgrid/protocols/web/WebConnector";
import { Driver } from "tgrid/components/Driver";

import { ICalculator } from "../../controllers/ICalculator";

async function main(): Promise<void>
{
    //----
    // CONNECTION
    //----
    let connector: WebConnector = new WebConnector();
    await connector.connect("ws://127.0.0.1:10102");

    //----
    // CALL REMOTE FUNCTIONS
    //----
    // GET DRIVER
    let calc: Driver<ICalculator> = connector.getDriver<ICalculator>();

    // FUNCTIONS IN THE ROOT SCOPE
    console.log("1 + 6 =", await calc.plus(1, 6));
    console.log("7 * 2 =", await calc.multiplies(7, 2));

    // FUNCTIONS IN AN OBJECT (SCIENTIFIC)
    console.log("3 ^ 4 =", await calc.scientific.pow(3, 4));
    console.log("log (2, 32) =", await calc.scientific.log(2, 32));

    try
    {
        // TO CATCH EXCEPTION IS STILL POSSIBLE
        await calc.scientific.sqrt(-4);
    }
    catch (err)
    {
        console.log("SQRT (-4) -> Error:", err.message);
    }

    // FUNCTIONS IN AN OBJECT (STATISTICS)
    console.log("Mean (1, 2, 3, 4) =", await calc.statistics.mean(1, 2, 3, 4));
    console.log("Stdev. (1, 2, 3, 4) =", await calc.statistics.stdev(1, 2, 3, 4));

    //----
    // TERMINATE
    //----
    await connector.close();
}
main();
```

> ```python
> 1 + 6 = 7
> 7 * 2 = 14
> 3 ^ 4 = 81
> log (2, 32) = 5
> SQRT (-4) -> Error: Negative value on sqaure.
> Mean (1, 2, 3, 4) = 2.5
> Stdev. (1, 2, 3, 4) = 1.118033988749895
> ```




<!-- @templates([
    ["chapter", "2"],
    ["assets", "../assets/"],
    ["blockchain.md", "appendix/blockchain.md"],
    ["examples.md", "tutorial/examples.md"]
]) -->
<!-- @import("appendix/internal/strengths.md") -->




<!-- @templates([
    ["market.md", "tutorial/projects/market.md"]
]) -->
<!-- @import("appendix/internal/opportunities.md") -->
