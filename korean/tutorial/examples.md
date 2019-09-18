# Learn from Examples
> https://github.com/samchon/tgrid.examples

이번 장에서는 간단한 예제 코드를 통해, **TGrid** 에 대해 심도 있게 공부해보는 시간을 갖도록 하겠습니다. 더불어 **TGrid** 가 말하는 *Remote Function Call* 이 어떻게 생겨먹었는지, 왜 이를 사용하면 *Computers be a Computer* 가 되는지 또한 예증해보는 시간을 갖도록 하겠습니다.

  - Demonstration of **TGrid**, who makes <u>computers to be a computer</u>
    - [1. Remote Function Call](#1-remote-function-call)
    - [2. Remote Object Call](#2-remote-object-call)
    - [3. Object Oriented Network](#3-object-oriented-network)
    - [4. Remote Critical Section](#4-remote-critical-section)

## 1. Remote Function Call
*Remote Function Call* 이 무엇인지, 그리고 어떻게 사용하는 것인지, 아래 예제 코드를 통해 알아봅시다. 우리가 이번에 예제로 만들어볼 것은 원격 계산기로써, 서버는 간단한 사칙연산 계산기를 제공할 것이며 (provides), 클라이언트는 이를 사용하여 계산을 수행할 (remote function calls) 것입니다.

  - 서버: 사칙연산 제공
  - 클라이언트: 사칙연산 사용

### 1.1. Features
`ISimpleCalculator` 는 서버로부터 클라이언트에게 제공되는 함수들을 정의한 인터페이스입니다. 혹 벌써 눈치채신 분들도 계실 겁니다. 그렇습니다, `ISimpleCalculator` 는 바로 [Controller](concepts.md#23-controller) 가 될 녀석입니다. 그렇다면, `SimpleCalculator` 의 역할은 무얼까요? 맞습니다, 서버에서 사용할 [Provider](concepts.md#22-provider) 를 구현한 클래스입니다.

  - [`../controllers/ICalculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/controllers/ICalculator.ts#L8-L14)
  - [`../providers/Calculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/providers/Calculator.ts#L6-L28)

{% codegroup %}
```typescript::ICalculator.ts
export interface ISimpleCalculator
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;
    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;
}
```
```typescript::Calculator.ts
export class SimpleCalculator implements ISimpleCalculator
{
    public plus(x: number, y: number): number
    {
        return x + y;
    }
    public minus(x: number, y: number): number
    {
        return x - y;
    }
    
    public multiplies(x: number, y: number): number
    {
        return x * y;
    }
    public divides(x: number, y: number): number
    {
        if (y === 0)
            throw new Error("Divided by zero.");
        return x / y;
    }
}
```
{% endcodegroup %}

### 1.2. Server
앞서 얘기하기를, 이번 예제에서 서버의 역할이란, 클라이언트에게 사칙연산 계산기를 제공한다는 것이었습니다. 그렇다면, 서버 프로그램에 작성해야 할 코드는 간단합니다. 서버를 개설하고, 해당 서버로 접속해오는 클라이언트들에게 사칙연산 계산기 `SimpleCalculator` (be [Provider](concepts.md#22-provider)) 를 제공하는 것입니다.

#### [`simple-calculator/server.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/simple-calculator/server.ts)
```typescript
import { WebServer, WebAcceptor } from "tgrid/protocols/web";
import { SimpleCalculator } from "../../providers/Calculator";

async function main(): Promise<void>
{
    let server: WebServer = new WebServer();
    await server.open(10101, async (acceptor: WebAcceptor) =>
    {
        await acceptor.accept(new SimpleCalculator());
    });
}
main();
```

### 1.3. Client
드디어 대망의 클라이언트 프로그램을 만들 차례가 다가왔습니다. 대체 그놈의 *Remote Function Call* 이 무엇인지, 아래 두 코드를 비교해보시면 단박에 이해하실 수 있으실 겁니다. 두 코드를 비교해보면, 클라이언트가 서버로부터 제공되는 원격 계산기를 사용하는 코드와, 단일 프로그램에서 자체 계산기 클래스를 사용하는 코드가 비슷함을 확인하실 수 있습니다.

이를 전문적인 용어로, 비지니스 로직 (Business Logic) 코드가 완전히 유사하다고 말합니다. 물론, 두 코드가 완벽하게 100 % 일치하지는 않습니다. 도메인 로직으로써 클라이언트가 서버에 접속을 해야 한다던가, 비지니스 로직 코드부에 원격 함수를 호출할 때마다 `await` 이라는 심벌이 추가로 붙는다던가 하는 등의 소소한 차이점들은 존재하기 때문입니다. 하지만, 근본적으로 두 코드의 비지니스 로직부는 완벽하게 동질의 것이며, 이로써 비지니스 로직을 네트워크 시스템으로부터 완벽하게 분리해낼 수 있었습니다. 동의하십니까?

네트워크로 연결되어있는 원격 시스템을, 처음부터 내 메모리 객체였던 거마냥, 자유로이 그것의 함수들을 호출할 수 있는 것. 이 것이 바로 *Remote Function Call* 입니다.

{% panel style="warning", title="여기서 잠깐! 꼭 알아두세요." %}

17 번째 라인에서 클라이언트가 서버로의 접속을 마친 후, 원격 함수를 호출하기 위해 [Communicator](concepts.md#21-communicator) 로부터 `connector.getDriver<ISimpleCalculator>()` 메서드를 호출함으로써 [Driver](concepts.md#23-driver)<[Controller](concepts.md#24-controller)> 객체를 구성한 것을 보실 수 있습니다. 

이처럼 원격 시스템이 제공하는 [Provider](concepts.md#22-provider) 에 대한 모든 원격 함수 호출은 언제나 이 [Driver](concepts.md#23-driver)<[Controller](concepts.md#24-controller)> 를 통해 이루어집니다. 이 부분은 앞으로 모든 튜토리얼에서 계속하여 반복하게 될 내용입니다. 꼭 숙지해주세요.

{% endpanel %}

#### [`simple-calculator/client.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/simple-calculator/client.ts)
{% codegroup %}
```typescript::Remote Function Call
import { WebConnector } from "tgrid/protocols/web/WebConnector";
import { Driver } from "tgrid/components/Driver";
import { ISimpleCalculator } from "../../controllers/ICalculator";

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
    let calc: Driver<ISimpleCalculator> = connector.getDriver<ISimpleCalculator>();

    // CALL FUNCTIONS WITH AWAIT SYMBOL
    console.log("1 + 3 =", await calc.plus(1, 3));
    console.log("7 - 4 =", await calc.minus(7, 4));
    console.log("8 x 9 =", await calc.multiplies(8, 9));

    // TO CATCH EXCEPTION IS ALSO POSSIBLE
    try 
    {
        await calc.divides(4, 0);
    }
    catch (err)
    {
        console.log("4 / 0 -> Error:", err.message);
    }

    //----
    // TERMINATE
    //----
    await connector.close();
}
main();
```
```typescript::Single Program
import { SimpleCalculator } from "../../providers/Calculator";

function main(): void
{
    //----
    // CALL FUNCTIONS
    //----
    // CONSTRUCT CALCULATOR
    let calc: SimpleCalculator = new SimpleCalculator();

    // CALL FUNCTIONS DIRECTLY
    console.log("1 + 3 =", calc.plus(1, 3));
    console.log("7 - 4 =", calc.minus(7, 4));
    console.log("8 x 9 =", calc.multiplies(8, 9));

    // TO CATCH EXCEPTION
    try 
    {
        calc.divides(4, 0);
    }
    catch (err)
    {
        console.log("4 / 0 -> Error:", err.message);
    }
}
main();
```
{% endcodegroup %}

> ```python
> 1 + 3 = 4
> 7 - 4 = 3
> 8 x 9 = 72
> 4 / 0 -> Error: Divided by zero.
> ```




## 2. Remote Object Call
우리는 지난 장 [1. Remote Function Call](#1-remote-function-call) 을 통하여 원격 시스템의 함수를 호출하는 방법을 알아봤습니다. 하지만, 여지껏 다루었던 것들은 어디까지나 단순 구조체 (Singular Structure) 로써 모든 함수들은 최상위 객체로써 정의되어있었을 뿐, 단 한 번도 <u>복합 구조체</u> (Composite Structure) 를 다루었던 적이 없습니다.

만일 여러분께서 사용하시려는 원격 객체 ([Provider](concepts.md#22-provider)) 가 복합 구조체라면 어떻게 하시겠습니까? 호출하고자 하는 최종 함수가 여러 객체들로 쌓여있어서, 객체에 객체의 꼬리를 물며 타고들어가야 비로소 접근할 수 있는 성질의 것이라면요? 이럴 때 **TGrid** 의 답변은 간단하고 명쾌합니다.

{% panel style="success", title="TGrid 의 한 마디" %}

그냥 쓰세요~!

{% endpanel %}

### 2.1. Features
이번 장에서 복합 구조체 호출 (Remote Object Call) 에 대한 예증을 위해 사용할 객체는 `CompositeCalculator` 입니다. 이 클래스는 이전 장에서 사용했던 [SimpleCalculator](#11-features) 의 사칙연산에 더하여, 내부 객체로써 공학용 계산기 (`scientific`) 와 통계용 계산기 (`statistics`) 가 추가된 복합 구조체의 형태를 띄고 있습니다.

뭐 이미 다 아시리라 생각됩니다만, 우리가 이번에 만들 (원격 복합 계산기) 예제에서 `ICompositeCalculator` 는 [Controller](#23-controller) 의 역할을 수행하게 될 것입니다. 그리고 `CompositeCalculator` 는 [Provider](#22-provider) 가 되겠죠.

  - [`../controllers/ICalculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/controllers/ICalculator.ts)
  - [`../providers/Calculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/providers/Calculator.ts)

{% codegroup %}
```typescript::ICalculator.ts
export interface ICompositeCalculator 
    extends ISimpleCalculator
{
    scientific: IScientific;
    statistics: IStatistics;
}

export interface ISimpleCalculator
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;
    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;
}
export interface IScientific
{
    pow(x: number, y: number): number;
    sqrt(x: number): number;
    log(x: number, y: number): number;
}
export interface IStatistics
{
    mean(...elems: number[]): number;
    stdev(...elems: number[]): number;
}
```
```typescript::Calculator.ts
import { 
    ICompositeCalculator, 
    ISimpleCalculator, IScientific, IStatistics
} from "../controllers/ICalculator";

export class SimpleCalculator 
    implements ISimpleCalculator
{
    public plus(x: number, y: number): number
    {
        return x + y;
    }
    public minus(x: number, y: number): number
    {
        return x - y;
    }
    
    public multiplies(x: number, y: number): number
    {
        return x * y;
    }
    public divides(x: number, y: number): number
    {
        if (y === 0)
            throw new Error("Divided by zero.");
        return x / y;
    }
}

export class CompositeCalculator
    extends SimpleCalculator
    implements ICompositeCalculator
{
    public scientific = new Scientific();
    public statistics = new Statistics();
}

export class Scientific implements IScientific
{
    public pow(x: number, y: number): number
    {
        return Math.pow(x, y);
    }

    public log(x: number, y: number): number
    {
        if (x < 0 || y < 0)
            throw new Error("Negative value on log.");
        return Math.log(y) / Math.log(x);
    }

    public sqrt(x: number): number
    {
        if (x < 0)
            throw new Error("Negative value on sqaure.");
        return Math.sqrt(x);
    }
}

export class Statistics implements IStatistics
{
    public mean(...elems: number[]): number
    {
        let ret: number = 0;
        for (let val of elems)
            ret += val;
        return ret / elems.length;
    }

    public stdev(...elems: number[]): number
    {
        let mean: number = this.mean(...elems);
        let ret: number = 0;

        for (let val of elems)
            ret += Math.pow(val - mean, 2);

        return Math.sqrt(ret / elems.length);
    }
}
```
{% endcodegroup %}

### 2.2. Server
서버 코드, 달리 설명할 게 있나요? 이전 [1. Remote Function Call](#11-server) 때와 달라진 것은 오로지 단 하나, 클라이언트에게 제공할 [Provider](concepts.md#22-provider) 가 `SimpleCalculator` 에서 `CompositeCalculator` 로 바뀌었다는 것 뿐입니다. 아, 그리고보니 포트 번호도 바뀌긴 했네요.

#### [`composite-calculator/server.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/composite-calculator/server.ts)
{% codegroup %}
```typescript::Remote Object Call
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
```typescript::Remote Function Call
import { WebServer, WebAcceptor } from "tgrid/protocols/web";
import { SimpleCalculator } from "../../providers/Calculator";

async function main(): Promise<void>
{
    let server: WebServer = new WebServer();
    await server.open(10101, async (acceptor: WebAcceptor) =>
    {
        await acceptor.accept(new SimpleCalculator());
    });
}
main();
```
{% endcodegroup %}

### 2.3. Client
클라이언트 프로그램에서도 [Controller](concepts.md#23-controller) 가 `ISimpleCalculator` 에서 `ICompositeCalculator` 로 바뀌었습니다. 그리고 호출하게 되는 대상 함수들의 범위도 *root scope* 에서 *composite scope* 로 변화했구요. 하지만, 보시다시피 원격 함수를 호출하는 데에는 아무런 문제가 없습니다.

구태여 제가 composite scope 형태의 원격 함수 호출을 것을 일컬어 *Remote Object Call* 이라 이름지었지만, 이는 근본적으로 이전의 [Remote Function Call](#13-client) 과 완전히 같습니다. 원격 시스템을 위해 제공되는 [Provider](concepts.md#22-provider) 와, 이를 사용하기 위한 [Controller](concepts.md#23-controller) 는 단순 구조체에서 복합 구조체로 바뀌었습니다. 그러함에도 여전히, <u>비지니스 로직 코드</u>는 네트워크 시스템을 구성할 때와 단일 프로그램을 만들 때가 <u>완전히 유사</u>합니다.

네트워크로 연결되어있는 원격 시스템을, 처음부터 내 메모리 객체였던 거마냥, 자유로이 그것의 메서드들을 호출할 수 있는 것. 이 것이 바로 Remote Object Call 입니다.

#### [`composite-calculator/client.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/composite-calculator/client.ts)
{% codegroup %}
```typescript::Remote Object Call
import { WebConnector } from "tgrid/protocols/web";
import { Driver } from "tgrid/components";

import { ICompositeCalculator } from "../../controllers/ICalculator";

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
    let calc: Driver<ICompositeCalculator> = connector.getDriver<ICompositeCalculator>();

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
```typescript::Single Program
import { CompositeCalculator } from "../../providers/Calculator";

function main(): void
{
    //----
    // CALL FUNCTIONS
    //----
    // CONSTRUCT CALCULATOR
    let calc: CompositeCalculator = new CompositeCalculator();

    // FUNCTIONS IN THE ROOT SCOPE
    console.log("1 + 6 =", calc.plus(1, 6));
    console.log("7 * 2 =", calc.multiplies(7, 2));

    // FUNCTIONS IN AN OBJECT (SCIENTIFIC)
    console.log("3 ^ 4 =", calc.scientific.pow(3, 4));
    console.log("log (2, 32) =", calc.scientific.log(2, 32));

    try
    {
        // TO CATCH EXCEPTION
        calc.scientific.sqrt(-4);
    }
    catch (err)
    {
        console.log("SQRT (-4) -> Error:", err.message);
    }

    // FUNCTIONS IN AN OBJECT (STATISTICS)
    console.log("Mean (1, 2, 3, 4) =", calc.statistics.mean(1, 2, 3, 4));
    console.log("Stdev. (1, 2, 3, 4) =", calc.statistics.stdev(1, 2, 3, 4));
}
main();
```
{% endcodegroup %}

> ```python
> 1 + 6 = 7
> 7 * 2 = 14
> 3 ^ 4 = 81
> log (2, 32) = 5
> SQRT (-4) -> Error: Negative value on sqaure.
> Mean (1, 2, 3, 4) = 2.5
> Stdev. (1, 2, 3, 4) = 1.118033988749895
> ```




## 3. Object Oriented Network
이번 장에서는 이전 장 [2. Remote Object Call](#2-remote-object-call) 에서 만들었던 원격 복합 계산기를 다시, 하지만 조금 다르게 만들어볼 것입니다; *계층형 계산기*. 이전의 복합 계산기 `CompositeCalculator` 는 그 내부에 멤버객체로써, 공학용 계산기와 통계용 계산기를 가지고 있습니다. 이번 장에서 새로이 만들어 볼 *계층형 계산기* 에서는, 이들 공학용 계산기와 통계용 계산기가 별도 서버로 분리됩니다.

즉, 이번 장에서는 기존의 단일 복합 계산기 서버가 총 세 대로 서버로 분리되어야 합니다. 제일 먼저 공학용 계산을 전담하는 `scientific` 서버와 통계용 계산을 전담하는 `statistics` 서버를 새로이 만들 것입니다. 그리고 스스로는 사칙연산을 전담하며, 여타 계산에 대해서는 *scientific* 및 *statistics* 서버들에게 대신 맡기는 메인프레임 서버 `calculator` 를 구성할 것입니다.

서버를 모두 제작한 뒤에는, 마지막으로 이들 계층형 계산기를 사용할 클라이언트 프로그램을 만들어야겠죠? 자, 과연 네트워크 시스템의 구조가 이처럼 크게 변화해도, 비지니스 로직 코드는 여전히 이전과 유사할까요? 한 번 프로그램을 직접 만들어보며 알아봅시다.

![Diagram of Composite Calculator](../../assets/images/examples/composite-calculator.png) | ![Diagram of Hierarchical Calculator](../../assets/images/examples/hierarchical-calculator.png)
:-------------------:|:-----------------------:
Composite Calculator | Hierarchical Calculator

### 3.1. Features
이번 장에서 메인프레임 서버가 사용할 [Controller](concepts.md#23-controller) 는 `IScientific` 와 `ISatistics` 이며, 클라이언트가 사용할 [Controller](concepts.md#23-controller) 는 `ICompositeCalculator` 입니다. 그런데 잠깐! 클라이언트가 사용하는 [Controller](concepts.md#23-controller) 는 이전 장 [2. Remote Object Call](#2-remote-object-call) 때와 완전히 동일하네요? 혹시 감이 오시나요?

마찬가지로 공학용 계산기와 통계용 계산기가 메인프레임 서버에 제공할 [Provider](concepts.md#22-provider) 는 각각 `Scientific` 와 `Statistics` 클래스이며, 메인프레임 서버가 클라이언트에게 제공할 [Provider](concepts.md#22-provider) 는 `HierarchicalCalculator` 클래스입니다. 이 `HierarchicalCalculator` 를 보고 있노라면, 뭔가 느껴지는 바가 있지 않으십니까? 

혹여 *계층형 계산기* 시스템을 구성하는 각 인스턴스가 사용할 [Controller](concepts.md#23-controller) 와 [Provider](concepts.md#22-provider) 를 본 것만으로도, 프로그램 코드를 어떻게 구현해야 할 지 감이 잡히신 분이라면, 축하드립니다. 당신은 이미 **TGrid** 에 대한 모든 것을 이해하신 겁니다.

  - [`../controllers/ICalculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/controllers/ICalculator.ts)
  - [`hierarchical-calculator/calculator.ts#L7-L13`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/hierarchical-calculator/calculator.ts#L7-L13)

{% codegroup %}
```typescript::ICalculator.ts
export interface ICompositeCalculator 
    extends ISimpleCalculator
{
    scientific: IScientific;
    statistics: IStatistics;
}

export interface ISimpleCalculator
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;
    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;
}
export interface IScientific
{
    pow(x: number, y: number): number;
    sqrt(x: number): number;
    log(x: number, y: number): number;
}
export interface IStatistics
{
    mean(...elems: number[]): number;
    stdev(...elems: number[]): number;
}
```
```typescript::HierarchicalCalculator
import { Driver } from "tgrid/components";

import { SimpleCalculator } from "../../providers/Calculator";
import { IScientific, IStatistics } from "../../controllers/ICalculator";

export class HierarchicalCalculator 
    extends SimpleCalculator
{
    // REMOTE CALCULATORS
    public scientific: Driver<IScientific>;
    public statistics: Driver<IStatistics>;
}
```
{% endcodegroup %}

### 3.2. Servers
#### [`hierarchical-calculator/scientific.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/hierarchical-calculator/scientific.ts)
공학용 계산기 서버를 만듦니다. 참 쉽죠?

```typescript
import { WorkerServer } from "tgrid/protocols/workers";
import { Scientific } from "../../providers/Calculator";

async function main(): Promise<void>
{
    let server: WorkerServer<Scientific> = new WorkerServer();
    await server.open(new Scientific());
}
main();
```

#### [`hierarchical-calculator/statistics.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/hierarchical-calculator/statistics.ts)
공학용 계산기 서버도 만들어줍니다. 이 역시 매우 간단합니다.

```typescript
import { WorkerServer } from "tgrid/protocols/workers";
import { Statistics } from "../../providers/Calculator";

async function main(): Promise<void>
{
    let server: WorkerServer<Statistics> = new WorkerServer();
    await server.open(new Statistics());
}
main();
```

####  [`hierarchical-calculator/calculator.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/hierarchical-calculator/calculator.ts)
자, 이제 메인프레임 서버를 만들 차례입니다. 

메인프레임 서버는 사칙연산은 스스로 수행하되, 공학용 계산이나 통계용 서버는 별도의 서버에 맡기고 자신은 그 연산결과만을 중개합니다. 이는 곧 메인프레임 서버가 클라이언트에게 제공하는 [Provider](concepts.md#22-provider) 는 사칙연산에 대해서는 스스로 구현체를 가지고 있으되, 공학용 계산기와 통계용 계산기는 원격 시스템들로부터 [Driver](concepts.md#24-driver)<[Controller](concepts.md#23-controller)> 를 받아 클라이언트에게 우회 제공함을 의미합니다.

따라서 아래 메인프레임 서버의 코드를 보시면, 메인프레임 서버가 클라이언트에게 제공하는 [Provider](concepts.md#22-provider) 인, `HierarchicalCalculator` 클래스는 `SimpleCalculator` 를 상속함으로써 사칙연산에 대하여 스스로 구현체를 가지고 있습니다. 그리고 공학용 계산기와 통계용 계산기는 각각 해당 서버로부터 `Driver<IScientific>` 과 `Driver<IStatistics>` 를 받아와 이를 클라이언트에게 우회 제공하고 있음을 알 수 있습니다.

이로써 `HierarchicalCalculator` 는, 이전 장의 [CompositeCalculator](#21-features) 와 논리적으로 완전히 동일해졌습니다. 이 둘의 세부 구현 코드는 서로 다를 지라도, 동일한 인터페이스를 지니며 마찬가지로 동일한 기능을 제공합니다. 이쯤되면 굳이 클라이언트 프로그램의 코드를 직접 보지 않더라도, 머리 속에서 그것의 구현체가 어떻게 생겼을지 슬슬 상상이 되지 않나요?

{% codegroup %}
```typescript::Object-Oriented-Network
import { WorkerServer } from "tgrid/protocols/workers/WorkerServer";
import { WorkerConnector } from "tgrid/protocols/workers/WorkerConnector
import { Driver } from "tgrid/components/Driver";

import { SimpleCalculator } from "../../providers/Calculator";
import { IScientific, IStatistics } from "../../controllers/ICalculator";

class HierarchicalCalculator 
    extends SimpleCalculator
{
    // REMOTE CALCULATORS
    public scientific: Driver<IScientific>;
    public statistics: Driver<IStatistics>;
}

async function associate<Controller extends object>
    (module: string): Promise<Driver<Controller>>
{
    // DO CONNECT
    let connector: WorkerConnector = new WorkerConnector();
    await connector.connect(`${__dirname}/${module}.js`);

    // RETURN DRIVER
    return connector.getDriver<Controller>();
}

async function main(): Promise<void>
{
    // PREPARE REMOTE CALCULATORS
    let calc: HierarchicalCalculator = new HierarchicalCalculator();
    calc.scientific = await associate<IScientific>("scientific");
    calc.statistics = await associate<IStatistics>("statistics");

    // OPEN SERVER
    let server: WorkerServer<HierarchicalCalculator> = new WorkerServer();
    await server.open(calc);
}
main();
```
```typescript::Remote Object Call
import { WebServer } from "tgrid/protocols/web/WebServer";
import { WebAcceptor } from "tgrid/protocols/web/WebAcceptor";
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
{% endcodegroup %}

### 3.3. Client
메인프레임 서버에서 클라이언트를 위하여 [Provider](concepts.md#22-provider) 로 제공하는 `HierarchicalCalculator` 클래스는, 이전 장의 [CompositeCalculator](#21-features) 와 논리적으로 완전히 동일합니다. 이 둘의 세부 구현코드는 비록 서로 다를지라도, 클라이언트에게 제공하는 인터페이스는 완벽하게 똑같습니다.

즉, 이번 장에서 클라이언트 프로그램은, (이전 장에서 사용했던) `ICompositeCalculator` 를 다시 사용하게 됩니다. 사용하는 [Controller](concepts.md#24-controller) 가 이전과 같으며, 구현해야 될 비지니스 로직도 이전과 같다면, 결국에는 두 클라이언트 프로그램의 코드가 유사해지지 않겠습니까? 아래 코드를 보시면 실제로도 그러합니다. 두 코드는 너무나도 비슷하여, 무엇이 다른지조차 쉬이 찾기 힘듭니다.

{% panel style="warning", title="혹시 무엇이 다른지 못 찾으셨나요?" %}

11~12 번째 라인이 살짝 다릅니다. 접속해야 할 대상 서버 주소가 서로 다르거든요.

{% endpanel %}

바로 이 것이 **TGrid** 입니다. 만들고자 하는 시스템이 단일 컴퓨터에서 동작하는 프로그램이던, 네트워크 통신을 이용한 분산처리시스템이던 상관 없습니다. 심지어 같은 네트워크 시스템이라는 범주 안에서도, 그것의 분산처리 구조가 어찌 구성되는 지 또한 아무런 문제가 되지 않습니다. 그저 이것 하나만 기억하십시오.

(**TGrid** 와 함께라면) 어떠한 경우에도, 여러분의 비지니스 로직 코드는 항상 동일할 것입니다.

#### [`hierarchical-calculator/index.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/hierarchical-calculator/index.ts)
{% codegroup %}
```typescript::Object-Oriented-Network
import { WorkerConnector } from "tgrid/protocols/workers/WorkerConnector";
import { Driver } from "tgrid/components/Driver";

import { ICompositeCalculator } from "../../controllers/ICalculator";

async function main(): Promise<void>
{
    //----
    // CONNECTION
    //----
    let connector: WorkerConnector = new WorkerConnector();
    await connector.connect(__dirname + "/calculator.js");

    //----
    // CALL REMOTE FUNCTIONS
    //----
    // GET DRIVER
    let calc: Driver<ICompositeCalculator> = connector.getDriver<ICompositeCalculator>();

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
main().catch(exp =>
{
    console.log(exp);
});
```
```typescript::Remote Object Call
import { WebConnector } from "tgrid/protocols/web/WebConnector";
import { Driver } from "tgrid/components/Driver";

import { ICompositeCalculator } from "../../controllers/ICalculator";

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
    let calc: Driver<ICompositeCalculator> = connector.getDriver<ICompositeCalculator>();

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
```typescript::Single Program
import { CompositeCalculator } from "../../providers/Calculator";

function main(): void
{
    //----
    // CALL FUNCTIONS
    //----
    // CONSTRUCT CALCULATOR
    let calc: CompositeCalculator = new CompositeCalculator();

    // FUNCTIONS IN THE ROOT SCOPE
    console.log("1 + 6 =", calc.plus(1, 6));
    console.log("7 * 2 =", calc.multiplies(7, 2));

    // FUNCTIONS IN AN OBJECT (SCIENTIFIC)
    console.log("3 ^ 4 =", calc.scientific.pow(3, 4));
    console.log("log (2, 32) =", calc.scientific.log(2, 32));

    try
    {
        // TO CATCH EXCEPTION
        calc.scientific.sqrt(-4);
    }
    catch (err)
    {
        console.log("SQRT (-4) -> Error:", err.message);
    }

    // FUNCTIONS IN AN OBJECT (STATISTICS)
    console.log("Mean (1, 2, 3, 4) =", calc.statistics.mean(1, 2, 3, 4));
    console.log("Stdev. (1, 2, 3, 4) =", calc.statistics.stdev(1, 2, 3, 4));
}
main();
```
{% endcodegroup %}

> ```python
> 1 + 6 = 7
> 7 * 2 = 14
> 3 ^ 4 = 81
> log (2, 32) = 5
> SQRT (-4) -> Error: Negative value on sqaure.
> Mean (1, 2, 3, 4) = 2.5
> Stdev. (1, 2, 3, 4) = 1.118033988749895
> ```




## 4. Remote Critical Section
**TGrid** 를 사용하면, 여러 대의 컴퓨터를 사용하여 통신하는 네트워크 시스템도, 논리적으로 단 한대의 컴퓨터에서 동작하는 <u>단일 프로그램</u>처럼 만들 수 있습니다. 제가 이 장을 통하여 여러분께 보여드렸던 예제 코드들은 모두, 이러한 개념의 증명을 위함이기도 합니다. 

하지만, TGrid 가 네트워크 시스템을 논리적으로 단 한대의 컴퓨터에서 동작하는 단일 프로그램으로 만들어줄 수는 있어도, 이것이 곧 싱글 스레드 프로그램을 의미하는 것은 아닙니다. 오히려 논리적으로는 <u>멀티 스레드</u>에 훨씬 가깝습니다. 즉, 우리가 **TGrid** 를 통해 만드는 모든 시스템은, 논리적으로 (하나의 컴퓨터에서 동작하는) 멀티 스레드 프로그램인 셈입니다.

그렇다면, '멀티 스레드' 라는 단어를 들으셨을 때, 여러분은 제일 먼저 무엇이 떠오르나요? 아마 십중팔구 임계영역에 대한 제어문제가 아닐까 합니다. 보다 쉽게 와닿는 단어로는 *mutex* 가 있습니다. 멀티 스레드 프로그램을 만들 때 제일 중요한 게 바로 이 임계영역을 잘~ 제어해야 한다는 것입니다. 

기껏 **TGrid** 를 통해 분산처리 네트워크 시스템을 논리적으로 (하나의 컴퓨터에서 동작하는) 멀티 스레딩 프로그램으로 만들었는데, 임계영역 제어가 안 된다면 무슨 의미가 있겠습니까? 따라서 이번 장에서 알아볼 것은 바로 네트워크 수준의 임계영역을 제어하는 방법입니다. **TGrid** 에서는 네트워크 수준의 임계영역 제어라고 해봐야 특별히 어려운 것은 없습니다. 이 또한 그저 *Remote Function Call* 을 통하여, 원격 시스템에서 제공해준 함수를 호출해주기만 하면 끝나니까요.

{% panel style="info", title="라이브러리 추천" %}

### TSTL
TypeScript Standard Template Library
  - https://tstl.dev

임계영역을 제어하기 위한 라이브러리로, [TSTL](https://tstl.dev) 에서 지원하는 `<thread>` 모듈을 추천합니다. 여기서 지원하는 임계영역 제어에 관한 클래스들은 개별 프로그램에서도 사용할 수 있지만, **TGrid** 에서 네트워크 수준으로 원격 임계영역을 제어하고자 할 때 특히 유용합니다.

이번 장의 예제코드에서 사용하는 `Mutex` 역시, [TSTL](https://tstl.dev) 의 것을 사용합니다.

```typescript
import {
    ConditionVariable,
    Mutex, TimedMutex,
    SharedMutex, SharedTimedMutex,
    UniqueLock, SharedLock,
    Latch, Barrier, FlexBarrier,
    Semaphore
} from "tstl/thread";
```

{% endpanel %}

### 4.1. Features
이번 원격 임계영역 제어에 사용할 [Controller](concepts.md#23-controller) 와 [Provider](concepts.md#22-provider) 는 아래와 같습니다. 클라이언트는 서버에게 [Provider](concepts.md#22-provider) 로써 `CriticalSection` 클래스를 제공할 것이며, 서버는 [Controller](concepts.md#23-controller) 인 `ICriticalSection` 을 [Driver](concepts.md#24-driver) 로 랩핑하여 사용할 것입니다.

보시다시피 클라이언트와 서버가 공유하게 될 기능은 매우 간소합니다. 서버에서 클라이언트로의 원격 임계영역 제어에는 `IMutex` 객체가 쓰이겠죠? 마찬가지로 클라이언트가 서버에 제공하는 `print()` 함수는 당최 뭐에 쓰는 물건인지, 예제 코드를 보면서 천천히 알아봅시다.

{% codegroup %}
```typescript::child.ts - Controller
export interface ICriticalSection
{
    mutex: IMutex;

    print(character: string): void;
}

interface IMutex
{
    lock(): void;
    unlock(): void;
}
```
```typescript::index.ts - Provider
import { Mutex } from "tstl/thread/Mutex";

export class CriticalSection
{
    public mutex: Mutex = new Mutex();

    public print(character: string): void
    {
        process.stdout.write(str);
    }
}
```
{% endcodegroup %}

### 4.2. Client
![Diagram of Remote Critical Section](../../assets/images/examples/remote-critical-section.png)

클라이언트 프로그램은 총 4 개의 `WorkerServer` 들을 개설합니다. 그리고 각 서버들에게 [Provider](concepts.md#22-provider) 로써 `CriticalSection` 클래스를 제공합니다. 마지막으로 각 서버 인스턴스들에 대하여, 그들이 모두 자신의 작업을 마치기를 기다렸다가 프로그램을 종료합니다.

보시다시피 클라이언트 프로그램이 하는 일은 간단합니다. 그저 서버 프로그램들에게, 클라이언트 자신의 임계영역을 제어할 수 있는 [Provider](concepts.md#22-provider) 를 제공할 뿐입니다. 중요한 것은 각 서버 프로그램들이 이를 어떻게 사용하냐, 그리고 **TGrid** 에서 *Remote Function Call* 을 사용하면 정말 네트워크 수준에서 임계영역을 제어할 수 있으냐가 아닐까요?

#### [`thread/index.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/thread/index.ts)
```typescript
import { WorkerConnector } from "tgrid/protocols/workers/WorkerConnector";

import { Mutex } from "tstl/thread/Mutex";

class CriticalSection
{
    public mutex: Mutex = new Mutex();

    public print(str: string): void
    {
        process.stdout.write(str);
    }
}

async function main(): Promise<void>
{
    let workers: WorkerConnector<CriticalSection>[] = [];
    let provider: CriticalSection = new CriticalSection();

    //----
    // CREATE WORKERS
    //----
    for (let i: number = 0; i < 4; ++i)
    {
        // CONNECT TO WORKER
        let w: WorkerConnector<CriticalSection> = new WorkerConnector(provider);
        await w.connect(__dirname + "/child.js");

        // ENROLL IT
        workers.push_back(w);
    }

    //----
    // WAIT THEM ALL TO BE CLOSED
    //----
    let promises: Promise<void>[] = workers.map(w => w.join());
    await Promise.all(promises);
}
main();
```

### 4.3. Server
서버 프로그램은 클라이언트가 제공해 준 Mutex 를 사용, 네트워크 레벨에서 임계 영역을 제어합니다. 

아래 코드에서 보시다시피, 서버 프로그램은 제일 먼저 임의의 글자를 하나 만듦니다 (38 번째 라인). 그리고 약 1 ~ 2 초에 걸쳐 전 네트워크 시스템의 임계영역를 독점적으로 점유하며, 아까 만들어두었던 임의의 문자를 클라이언트의 콘솔에 반복하여 출력해줍니다 (19 ~ 33 번째 라인).

만약 **TGrid** 에서 말하는 *Remote Function Call* 이 네트워크 수준의 임계영역 제어마저 가능하다면, 콘솔에는 각 라인마다 동일한 글자가 반복될 것입니다. 반면에 **TGrid** 와 TSTL 이 네트워크 수준의 임계영역 제어에 실패한다면, 콘솔에는 서로 다른 글자가 혼란스럽게 뒤섞여있을 것입니다.

자, 과연 **TGrid** 는 네트워크 수준의 임계영역 마저도 구현해낼 수 있을까요? 아래 코드와 그 출력 결과를 함께 보시죠.

#### [`thread/child.ts`](https://github.com/samchon/tgrid.examples/blob/master/src/projects/thread/child.ts)
```typescript
import { WorkerServer } from "tgrid/protocol/worker/WorkerServer";
import { Driver } from "tgrid/components/Driver";

import { Mutex, sleep_for } from "tstl/thread";
import { randint } from "tstl/algorithm";

interface ICriticalSection
{
    mutex: Mutex;
    print(character: string): void;
}

async function main(character: string): Promise<void>
{
    // PREPARE SERVER & DRIVER
    let server: WorkerServer = new WorkerServer();
    let driver: Driver<ICriticalSection> = server.getDriver<ICriticalSection>();

    // REMOTE FUNCTION CALLS
    await driver.mutex.lock();
    {
        // RANDOM SLEEP -> SEQUENCE WOULD BE SHUFFLED
        await sleep_for(randint(50, 100));

        // PRINT A LINE WITH REPEATED LETTERS
        for (let i: number = 0; i < 20; ++i)
        {
            await driver.print(character); // PRINT A LETTER
            await sleep_for(randint(50, 100)); // RANDOM SLEEP
        }
        await driver.print("\n");
    }
    await driver.mutex.unlock();

    // CLOSE THE SERVER (WORKER)
    await server.close();
}
main(randint(0, 9) + "");
```

> ```python
> 11111111111111111111
> 88888888888888888888
> 44444444444444444444
> 33333333333333333333
> ```