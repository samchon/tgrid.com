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

더불어 `Communicator` 는 최상위 추상 클래스로써, **TGrid** 에서 네트워크 통신을 담당하는 클래스들은 모두 이 `Communicator` 클래스를 상속하고 있습니다. 이에 관한 자세한 내용은 [3. Protocols](#3-protocols) 단원을 참고해주세요.

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
TGrid 는 웹소켓 프로토콜 전용 Communicator 클래스들을 제공합니다.

아래 리스트는 **TGrid** 에서 웹 소켓 프로토콜을 이용하여 만든 예제 코드와 데모 프로젝트로입니다. **TGrid** 는 Web Socket 모듈의 [세부 컴포넌트들](#313-components)에 대하여 [API 문서](https://tgrid.dev/api/modules/tgrid_protocols_web.html)도 제공하지만, 아래 예제와 데모 프로젝트들을 함께 보시면 훨씬 더 유익할 것입니다.

  - 예제 코드
    - [Remote Function Call](examples.md#1-remote-function-call)
    - [Remote Object Call](examples.md#2-remote-object-call)
  - 데모 프로젝트
    - [Chat Application](projects/chat-application.md)
    - [Omok Game](projects/omok-game.md)
    - [Fog Computing](projects/fog-computing.md)


#### 3.1.1. WebServer
Web Socket Server

`WebServer` 는 웹소켓 서버를 개설할 수 있는 클래스입니다. `WebServer` 로 서버에 클라이언트가 접속할 때마다 [WebAcceptor](#312-webacceptor) 객체가 새로이 생성될 것이며, 해당 클라이언트와의 통신은 바로 이 [WebAcceptor](#312-webacceptor) 객체를 통하여 이루어질 것입니다.

> `WebServer` 는 [Communicator](#21-communicator) 클래스가 아닙니다. [WebAcceptor](#312-webacceptor) 가 [Communicator](#21-communicator) 클래스입니다.

`WebServer` 클래스를 이용해 웹소켓 서버를 개설하시려거든, [*WebAcceptor.open()*](https://tgrid.dev/api/classes/tgrid_protocols_web.webacceptor.html#accept) 메서드를 호출해주십시오. 이 때, 파라미터에 입력하게 되는 콜백 함수는 매번 새로운 클라이언트가 접속할 때마다 새로운 [WebAcceptor](#312-webacceptor) 객체와 함께 호출될 것입니다.

#### 3.1.2. WebAcceptor
Web Socket Acceptor

`WebAcceptor` 클래스는 [WebServer](#311-webserver) 로 개설한 웹소켓 서버에 접속한 클라이언트와의 네트워크 통신을 담당하는 [Communicator](#21-communicator) 클래스입니다. `WebAcceptor` 인스턴스는 [WebServer](#311-webserver) 로 개설한 서버에 클라이언트가 접속했을 때, 이에 대응하는 개념으로써 생성되며, 대상 클라이언트와는 언제나처럼 [Remote Function Call](#remote-function-call) 을 이용하여 통신합니다.

> 클라이언트는 해당 서버에, 반드시 [WebConnector](#313-webconnector) 를 이용하여 접속해야 합니다.

클라이언트로부터의 접속을 최종 허락하고 연동을 시작하시려거든, [*WebAccpetor.accept()*](https://tgrid.dev/api/classes/tgrid_protocols_web.webacceptor.html#accept) 메서드를 호출해주십시오. 이 때 파라미터로 대상 클라이언트에게 제공할 [Provider](#22-provider) 역시 지정해주셔야 합니다. 그리고 모든 일이 끝난 다음에, [*WebAcceptor.close()*](https://tgrid.dev/api/classes/tgrid_protocols_web.webacceptor.html#close) 를 호출하여, 클라이언트와의 네트워크 연결을 반드시 종료해주십시오.

#### 3.1.3. WebConnector
Web Socket Connector

`WebConnector` 는 클라이언트에서 사용하는 [Communicator](#21-communicator) 클래스로써, [WebServer](#311-webserver) 클래스를 이용하여 개설한 웹소켓 서버에 접속하여, 해당 서버 내 [WebAcceptor](#312-webacceptor) 객체와 [Remote Function Call](#12-remote-function-call) 로 통신할 수 있습니다.

웹소켓 서버로의 접속은 [*WebConnector.connect()*](https://tgrid.dev/api/classes/tgrid_protocols_web.webconnector.html#connect) 메서드를 호출하면 됩니다. 다만, 이 때 접속 대상이 되는 웹소켓 서버는 반드시 [WebServer](#311-webserver) 클래스를 이용해 개설되었어야 합니다. 더불어 대상 서버는 해당 클라이언트의 접속에 대하여 [*WebAcceptor.accept()*](https://tgrid.dev/api/classes/tgrid_protocols_workers.sharedworkeracceptor.html#accept) 메서드를 호출함으로써 이를 '수락' 해야만이, 비로소 [Remote Function Call](#12-remote-function-call) 를 이용한 상호 연동이 시작될 것입니다.

마지막으로 네트워크 접속을 제 때 종료하지 않으면, 서버의 자원에 불필요한 낭비가 생기게 됩니다. 따라서 모든 일이 끝난 다음에는, 반드시 [*WebConnector.close()*](https://tgrid.dev/api/classes/tgrid_protocols_web.webconnector.html#close) 메서드를 호출하여 서버와의 네트워크 연결을 종료해주십시오. 그도 아니라면, 최소한 서버 프로그램이 [*WebAcceptor.close()*](https://tgrid.dev/api/classes/tgrid_protocols_web.webacceptor.html#close) 를 호출하여, 현재 클라이언트와의 네트워크 연결을 서버 스스로 해제할 수 있어야 합니다. 

### 3.2. Workers
TGrid 는 Workers 프로토콜 전용 [Communicator](#21-communicator) 클래스들을 제공합니다.

아래 리스트는 **TGrid** 에서 Workers 프로토콜을 이용하여 만든 예제 코드와 데모 프로젝트로입니다. **TGrid** 는 Workers 모듈의 [세부 컴포넌트들](#323-components)에 대하여 [API 문서](https://tgrid.dev/api/modules/tgrid_protocols_workers.html)도 제공하지만, 아래 예제와 데모 프로젝트들을 함께 보시면 훨씬 더 유익할 것입니다.

  - Examples
    - [Object Oriented Network](examples.md#3-object-oriented-network)
    - [Remote Critical Section](examples.md#4-remote-critical-section)
  - Projects
    - [Fog Computing](projects/fog-computing.md)

#### 3.2.1. `WorkerConnector`
#### 3.2.2. `WorkerServer`
#### 3.2.3. `SharedWorkerConnector`
#### 3.2.4. `SharedWorkerServer`
#### 3.2.5. `SharedWorkerAcceptor`

