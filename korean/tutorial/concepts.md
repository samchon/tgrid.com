# Basic Concepts
## 1. Outline
### 1.1. Grid Computing
### 1.2. Remote Function Call
### 1.3. Computers be a Computer



## 2. Components
### 2.1. Communicator
Communicates with Remote System.

`Communicator` 는 원격 시스템과의 네트워크 통신을 전담하는 객체입니다. 이 `Communicator` 에 상대방 시스템에게 제공할 [Provider](#22-provider) 를 등록할 수 있습니다. 상대방 시스템이 제공한 [Provider](#22-provider) 를 사용할 수 있는 [Driver](#24-driver)<[Controller](#23-controller)> 역시, 이 `Communicator` 를 통해 생성할 수 있습니다.

> `Communicator.getDriver<Controller>`

더불어 `Communicator` 는 추상 클래스로써, **TGrid** 에서 네트워크 통신에 관한 세부 프로토콜을 구현한 클래스들은 모두 이 `Communicator` 클래스를 상속하고 있습니다. 

{% codegroup %}
```typescript::Server
import { WebServer, WebAcceptor } from "tgrid/protocols/web";
import { Calculator } from "../providers/Calculator";

async function main(): Promise<void>
{
    let server: WebServer = new WebServer();
    let provider: Calculator = new Calculator();

    await server.open(10101, async (acceptor: WebAcceptor) =>
    {
        // PROVIDE CALCULATOR
        await accept.accept(provider);
    });
}
```
```typescript::Client
import { WebConnector } from "tgrid/protocols/web";
import { Driver } from "tgrid/components";
import { ICalculator } from "../controllers/ICalculator";

async function main(): Promise<void>
{
    //----
    // DO CONNECT
    //----
    let connector: WebConnector = new WebConnector();
    await connector.connect("http://127.0.0.1:10101");

    //----
    // CALL REMOTE FUNCTIONS
    //----
    // GET DRIVER PROVIDED BY SERVER
    let calc: Driver<ICalculator> = connector.getDriver<ICalculator>();

    // FUNCTIONS IN THE ROOT SCOPE
    console.log("1 + 6 =", await calc.plus(1, 6));
    console.log("7 * 2 =", await calc.multiplies(7, 2));

    // FUNCTIONS IN AN OBJECT (SCIENTIFIC)
    console.log("3 ^ 4 =", await calc.scientific.pow(3, 4));
    console.log("log (2, 32) =", await calc.scientific.log(2, 32));

    try
    {
        // TO CATCH EXCEPTION IS ALSO POSSIBLE
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
    // CLOSE CONNETION
    //----
    await connector.close();
}
```
{% endcodegroup %}

### 2.2. Provider
Object being provided for Remote System

`Provider` 는 원격 시스템에 제공할 객체입니다. 상대방 시스템은 현 시스템이 `Provider` 로 등록한 객체에 정의된 함수들을, [Driver](#24-driver)<[Controller](#23-controller)> 를 이용해 원격으로 호출할 수 있습니다. 

```typescript
export class Calculator
{
    public plus(x: number, y: number): number;
    public minus(x: number, y: number): number;
    public multiplies(x: number, y: number): number;
    public divides(x: number, y: number): number;

    public scientific: Scientific;
    public statistics: Statistics;
}
```

### 2.3. Controller
Interface for [Provider](#22-provider)

`Controller` 는 원격 시스템에서 제공하는 [Provider](#22-provider) 에 대한 인터페이스입니다.

```typescript
export interface ICalculator
{
    plus(x: number, y: number): number;
    minus(x: number, y: number): number;
    multiplies(x: number, y: number): number;
    divides(x: number, y: number): number;

    scientific: IScientific;
    statistics: IStatistics;
}
```

### 2.4. Driver
`Driver` of [Controller](#23-controller) for [RFC](#12-remote-function-call)

`Driver` 는 원격 시스템의 함수를 호출할 때 사용하는 객체입니다. 제네릭 파라미터로써 [Controller](#23-controller) 를 지정하게 되어있으며, 바로 이 `Driver<Controller>` 객체를 통해, 원격 시스템에서 현 시스템을 위해 제공한 [Provider](#22-provider) 객체의, 함수를 원격 호출할 수 있습니다. 바로 이 `Driver<Controller>` 객체를 통해 이루어진 원격 함수 호출을 일컬어, [Remote Function Call](#12-remote-function-call) 라고 합니다.

더불어 `Driver` 의 제네릭 타입에 [Controller](#23-controller) 를 할당하거든, 해당 [Controller](#23-controller) 에 정의된 모든 함수들의 리턴타입은 *Promise* 화 됩니다. 만약 대상 [Controller](#23-controller) 안에 내부 오브젝트가 정의되어있거든, 해당 오브젝트 역시 `Driver<object>` 타입으로 변환됩니다. 그리고 이는 재귀적으로 반복되기에 최종적으로 [Controller](#23-controller) 에 정의된 함수들은 모두, 그것의 계층 깊이에 상관없이, *Promise* 화 됩니다. 

```typescript
type Driver<ICalculator> = 
{
    plus(x: number, y: number): Promise<number>;
    minus(x: number, y: number): Promise<number>;
    multiplies(x: number, y: number): Promise<number>;
    divides(x: number, y: number): Promise<number>;

    scientific: Driver<IScientific>;
    statistics: Driver<IStatistics>;
};
```




## 3. Protocols
### 3.1. Web Socket
#### 3.1.1. Outline
TGrid 는 웹소켓 프로토콜 전용 Communicator 클래스들을 제공합니다.

#### 3.1.2. Components
Supports     | Web Browser | NodeJS
-------------|-------------|--------
WebServer    | X           | O
WebAcceptor  | X           | O
WebConnector | O           | O

#### 3.1.3. Related Tutorials
  - Examples
    - [Remote Function Call](examples.md#1-remote-function-call)
    - [Remote Object Call](examples.md#2-remote-object-call)
  - Projects
    - [Chat Application](projects/chat-application.md)
    - [Omok Game](projects/omok-game.md)
    - [Fog Computing](projects/fog-computing.md)

### 3.2. Workers
TGrid 는 Worker 프로토콜 전용 Communicator 클래스들을 제공합니다.

#### 3.2.1. Outline

#### 3.2.2. Components
Supports              | Web Browser | NodeJS
----------------------|-------------|--------
WorkerServer          | O           | O
WorkerConnector       | O           | O
SharedWorkerServer    | O           | X
SharedWorkerAcceptor  | O           | X
SharedWorkerConnector | O           | X

#### 3.2.3. Related Tutorials
  - Examples
    - [Object Oriented Network](examples.md#3-object-oriented-network)
    - [Remote Critical Section](examples.md#4-remote-critical-section)
  - Projects
    - [Fog Computing](projects/fog-computing.md)