# SWOT Analysis
## 1. Strengths
### 1.1. Easy Development
누구나 쉽게 네트워크 연동 시스템을 만들 수 있습니다.

본래 네트워크 통신을 이용한 연동시스템을 만드는 것은 제법 어려운 일입니다. 여러 대의 컴퓨터가 어우러져 공통의 작업을 해내야 하기 때문입니다. 따라서 네트워크 연동 시스템을 개발할 때는 (요구사항을 완벽하게 분석해야 하고, 유즈케이스를 완벽하게 파악해야 하며, 데이터와 네트워크 아키텍처를 완벽하게 설계해야 하고, 상호 연동 테스트를 완벽하게 해야 하는 하는등) 프로세스의 온갖 곳에 '완벽' 이라는 무시무시한 수식어가 따라다닙니다.

{% panel style="info", title="Something to Read" %}
[블록체인의 Network System, 지옥으로의 발걸음](blockchain.md#steps-to-hell)
{% endpanel %}

하지만, **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 이용하면, 진정한 [Grid Computing](../tutorial/concepts.md#11-grid-computing) 을 실현할 수 있습니다. 네트워크로 연동된 여러 대의 컴퓨터들은 단 <u>하나의 가상 컴퓨터</u>로 치환됩니다. 심지어 이렇게 만들어진 가상 컴퓨터에서 동작하는 프로그램의 *비지니스 로직* 코드는, 실제로 단일 컴퓨터에서 동작하는 단일 프로그램의 *비지니스 로직* 코드와 동일하기까지 합니다.

따라서 **TGrid** 를 이용하시거든 네트워크 연동 시스템을 매우 쉽게 만드실 수 있습니다. 복잡하고 어려운 네트워크 프로토콜이니 메시지 구조 설계니 하는 것들은 모두 잊어버리십시오. 오로지 여러분께서 만들고자 하는 것의 본질, *비지니스 로직*, 그 자체에만 집중하십시오. **TGrid** 를 사용하시는 이상, 여러분은 단지 한 대의 (가상) 컴퓨터에서 동작하는 단일 프로그램을 개발하는 것일 뿐입니다.

### 1.2. Safe Implementation
컴파일과 타입 검사를 통해, 안전한 네트워크 시스템을 만들 수 있습니다.

네트워크 통신을 이용한 분산처리시스템을 만들 때, 가장 곤혹스러운 것 중에 하나가 바로 런타임 에러입니다. 네트워크로 송수신되는 메시지가 제대로 구성되었는지, 그리고 이를 제대로 파싱하였는지, 모두 컴파일 시점이 아닌 런타임 시점에서야 오류를 인지할 수 있습니다. 

종래의 방법으로 구현한 분산처리시스템에, 실은 중대한 오류가 하나 있습니다. 그리고 이를 서비스 개시 이후에나 알게 된다면, 이 얼마나 끔찍한 일이겠습니까? 그렇다고 발생 가능한 모든 네트워크 메시지와 이를 사용하는 모든 시나리오들에 대한 테스트 프로그램을 만들자니, 이 또한 얼마나 고된 일이겠습니까? 처음부터 컴파일 개념만 제대로 지원되었다면, 모든 게 참 간단했을텐데요.

**TGrid** 는 네트워크 분산처리시스템의 이러한 컴파일 이슈에 대하여 정확한 솔루션을 제공합니다. **TGrid** 는 진정한 [Grid Computing](../tutorial/concepts.md#11-grid-computing) 을 구현하기 위하여, 네트워크 통신에 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 이란 개념을 도입하였습니다. [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 이란 무엇입니까? 함수 호출 그 자체 아니던가요? 당연하게도 TypeScript Compiler 의 보호를 받아, 타입 안정성을 보장받는 대상입니다.

즉, **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 를 사용하시거든, 무려 네트워크 시스템에 컴파일과 타입 검사라는 개념을 도입하실 수 있습니다. 그리고 이를 통해 안전하고 편안한 네트워크 시스템 구축이 가능해지죠. 백문이 불여일견, **TGrid** 를 이용한 *Safe Implementation* 의 사례를 보면서, 이번 장을 마치겠습니다.

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

### 1.3. Network Refactoring
네트워크 시스템에의 중대 변화도 매우 유연하게 대처할 수 있습니다.

네트워크 분산처리시스템을 만들다보면 늘상 생기는 이슈가 있습니다. 그것은 바로 기존의 네트워크 시스템에 어떠한 이유로 '중대 변화' 를 주어야 할 필요성이 생긴다는 것입니다. 마치 소프트웨어 리팩토링 마냥, 네트워크 시스템 수준에서도 *리팩토링* 이 필요해지는 순간이 온다는 것입니다.

그리고 그 중에 가장 대표적인 것이 바로 *performance* 이슈입니다. 본래 한 대의 컴퓨터로 처리할 수 있다고 여겨지던 작업이 있는데, 실제 서비스를 가동하여보니 워낙 연산량이 많아 이를 여러 대의 컴퓨터에 분할하여 처리해야 할 수도 있습니다. 반대로 여러 대의 컴퓨터를 준비해놨건만, 실제로는 단 한 대의 컴퓨터로도 충분했다거나 그 조차도 필요없어 해당 기능을 다른 컴퓨터에 병합해야 할 수도 있는 법입니다.

![Diagram of Composite Calculator](../../assets/images/examples/composite-calculator.png) | ![Diagram of Hierarchical Calculator](../../assets/images/examples/hierarchical-calculator.png)
:-------------------:|:-----------------------:
[Composite Calculator](../tutorial/examples.md#22-remote-object-call) | [Hierarchical Calculator](../tutorial/examples.md#23-object-oriented-network)

이 performance 이슈로 인한 *네트워크 리팩토링* 에 대해, 간단한 예시를 들어 설명하도록 하겠습니다. 어떤 분산처리시스템에, 계산기 역할을 수행하는 서버가 한 대 있었습니다. 그런데 이 시스템을 운영해보니, 연산량이 워낙 막중하여 도저히 단 한 대의 서버로는 감당이 안 되었고, 따라서 해당 서버를 총 세 대의 서버로 분할하기로 결심합니다.

  - [`scientific`](../tutorial/examples.md#hierarchical-calculatorscientificts): 공학용 계산기 서버
  - [`statistics`](../tutorial/examples.md#hierarchical-calculatorstatisticsts): 통계용 계산기 서버
  - [`calculator`](../tutorial/examples.md#hierarchical-calculatorcalculatorts): 메인 프레임 서버
    - 사칙 연산은 스스로 수행하고
    - 공학용과 통계용은 다른 서버에게 전달하고 그 결과값만을 중개

만일 이 것을 **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 거치지 않고 종래의 방법대로 해결하려거든, 매우 고된 작업이 될 것입니다. 우선 세 대의 서버간 통신에 사용할 메시지 프로토콜부터 설계해줘야 합니다. 그리고 해당 메시지 프로토콜에 맞는 파서들을 제작해줘야 하고, 새로이 정의된 네트워크 아키텍처에 따라 이벤트 핸들링도 다시 해 줘야 합니다. 마지막으로 이러한 과정이 잘 이루어졌는지 검증해보는 것인 덤이겠죠?

> 변하게 되는 것들
>  - 네트워크 아키텍처
>  - 메시지 프로토콜
>  - 이벤트 핸들링
>  - *비지니스 로직* 코드

하지만 **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 이용하면 이러한 이슈는 아무런 문젯거리도 되지 못합니다. TGrid 에서는 네트워크 시스템을 구성하는 각 서버도, 단지 일개 객체일 뿐입니다. 원격 계산기를 한 대의 서버로 만들던, 세 대의 서버에 나누어 처리하던, 그것의 비지니스 로직 코드는 모두 동일할 것입니다.

이를 가장 잘 보여주는 게 아래 두 예제입니다. 첫 번째는 단일 계산기의 코드이며, 두 번째는 해당 계산기 서버를 세 대의 서버로 분할했을 때의 코드입니다. 이를 보시면 쉬이 알 수 있듯이, **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 사용하시거든 네트워크 시스템 구조가 대거 변하더라도, 여러분께선 아무 염려하지 않으셔도 됩니다.

  - [Demonstration - Remote Object Call](../tutorial/examples.md#22-remote-object-call)
  - [Demonstration - Object Oriented Network](../tutorial/examples.md#23-object-oriented-network)




## 2. Weaknesses
### 2.1. High Traffic
네트워크 통신에서 범용성의 동의어는 오버헤드, 즉 트래픽 증가입니다.

> 하지만 트래픽 따위, 무시해도 좋습니다

TGrid 에서 [Grid Computing](../tutorial/concepts.md#11-grid-computing) 을 실현하기 위해 내세운 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call), 우리는 이를 통하여 [1. Strengths](#1-strengths) 의 이점들을 누리고 있습니다. 하지만 빛이 있으면 어둠도 있는 법, [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 실현핳기 위해 [Communicator](../tutorial/concepts.md#21-communicator) 가 네트워크 통신에 사용하는 데이터 구조는 JSON-string 으로써, 높은 범용성을 가지는 대신 데이터 전송량도 함께 늘어난다는 단점을 가지고 있습니다.

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

네트워크 통신을 함에 있어 데이터 전송량을 줄일 때 쓰는 가장 정석적인 방법은, 바로 전용 데이터 (binary structure) 를 설계하여 사용하는 것입니다. 네트워크 송수신이 이루어지는 모든 기능 단위에 각 기능 단위만을 위한 최적의 전용 데이터 구조 (binary structure) 를 설계하여 적용하면, 데이터 전송량을 대폭 줄일 수 있습니다. 아래 예제의 경우, 전용 데이터 (binary structure) 는 개별 레코드 당 28 바이트를 사용하며, 범용 데이터 (JSON-string) 는 약 100 ~ 200 바이트를 사용합니다.

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

하지만, 저는 이리 생각합니다. 요즘 같은 시대에 그깟 트래픽이 무슨 대수겠는가?

오늘날의 네트워크 통신 기술은 하루가 다르게 발전하여, 1 초에 GB 단위로 데이터를 전송할 수 있는 시대가 되었습니다. 데이터 전송량을 줄이고자 모든 기능 단위에 전용 binary structure 를 설계하여 사용한다라... 글쎄요, 과거 1 초에 전송할 수 있는 단위가 수 KB 에 지나지 않던 시대라면 모르겠습니다만, 요즘 같은 시대에 굳이 그렇게까지 해야할까요?

저라면 [1. Strengths](#1-strengths) 의 이점을 누리기 위해서 다소의 트래픽 증대 따위, 그냥 감수하겠습니다. 뭐 그럴라고 만든 **TGrid** 이긴 하지만요.

### 2.2. Low Performance
스크립트 기반 언어를 사용하기에, 퍼포먼스가 떨어집니다.

> 하지만 대책도 다 강구해두었습니다.
> 
>  - 그래도 [1. Strengths](#1-strengths) 의 이점이 더 크다
>  - 인프라 비용을 [3.2. Publish Grid](#32-publish-grid) 로 해소할 수 있습니다.
>  - *Low Performance* 는 부분 최적화로 해소할 수 있습니다.
>  - 추후 네이티브 언어로 바꾸더라도, 일단 **TGrid** 로 빠르고 안정적으로 개발하세요.

#### 2.2.1. Script Language
**TGrid** 의 풀네임은 TypeScript Grid Computing Framework 로써, 기반으로 삼고 있는 언어가 TypeScript 입니다. 그리고 TypeScript 의 컴파일 결과물은 JavaScript 이며, 당연하게도 스크립트 언어입니다. 그리고 프로그래머라면 누구나 다 알법한 사실이죠, 스크립트 언어는 네이티브 언어에 비해 느립니다. 따라서 **TGrid** 로 만든 [Grid Computing](../tutorial/concepts.md#11-grid-computing) 시스템은, 네이티브로 만든 것에 비해 느립니다.

때문에 우리는 [Grid Computing](../tutorial/concepts.md#11-grid-computing) 시스템을 만들 때, 한 가지 고민을 해 봐야 합니다. **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 사용해서 생기는 이점 [1. Strengths](#1-strengths) 가 스크립트 언어로 인하여 발생한 *Low Performance* 라는 약점을 충분히 상쇄할 수 있는지 아닌지.

물론, 여러분께서 만드시고자 하는 네트워크 시스템에 performance 이슈가 없거나, Grid Computing 시스템을 구현하고자 하는 이유가 초대형 연산을 분산하여 빠르게 처리하고자 함이 아니라 순전 비지니스 로직에 의함이라면 (대표적으로 블록체인), 이런 고민은 할 필요도 없겠죠? 이럴 때는 그냥 눈 딱 감고 **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 사용하세요.

![seesaw](../../assets/images/appendix/seesaw.gif)

#### 2.2.2. Partial Optimization
한 편, **TGrid** 가 이 *Low Performance* 이슈에 대하여, 아무런 대응전략도 없이 손을 놓은 것은 결코 아닙니다. *Low Performance* 그 자체로 인해 증대하는 인프라 비용은 [3.2. Publish Grid](#32-public-grid) 를 통해 상쇄할 수 있습니다 (추후 통계를 내 볼 것인데, 아마 비용이 단순히 상쇄되는 수준이 아니라 오히려 대폭 절감될 것이라고 예상합니다). 

그리고 *Low Performance* 그 자체도 나름대로 해소할 수 있는 방법이 있습니다. Performance Tuning 은 기대효과가 가장 큰 곳에서부터 시작하라고 하지 않습니까? 모든 프로그램 코드를 C++ 로 짤 필요는 없습니다. 기본적으로는 TypeScript 를 사용하여 만들되, 연산이 집중되는 구간들만을 네이티브 언어로 제작하여 연동하면 됩니다 (NodeJS 에서는 C++ 과의 직접적인 연동을 하면 되며, Web Browser 에서는 Web Assembly 와 연동하면 됩니다).

{% panel style="info", title="TypeScript Standard Template Library" %}

[TSTL](https://github.com/samchon/tstl) 은 C++ 표준위원회가 정의한 STL (Standard Template Library) 을 TypeScript 로 구현한 모듈입니다. 만일 프로그램을 제작할 때 [TSTL](https://github.com/samchon/tstl) 를 사용하신다면, 그것은 C++ 의 표준 라이브러리와 동일한 자료구조, 동일한 인터페이스를 사용한다는 얘기와 똑같습니다. 따라서 [TSTL](https://github.com/samchon/tstl) 로 제작된 프로그램만큼, C++ 로 마이그레이션하기 수월한 게 또 없습니다.

만일 여러분께서 제작하고 계시는 프로그램에 performance 이슈가 생길 것 같다구요? 따라서 추후 C++ 로 마이그레이션해야 할 가능성이 있다구요? 그렇다면 일말의 주저함 없이 [TSTL](https://github.com/samchon/tstl) 을 사용하십시오. [TSTL](https://github.com/samchon/tstl) 은 여러분께 참으로 놀라운 경험을 선사할 것입니다.

{% endpanel %}

#### 2.2.3. Full Migration
설령 여러분께서 [Grid Computing](../tutorial/concepts.md#11-grid-computing) 시스템 전체를 C++ 로 만들고자 하시더라도, 저는 여전히 **TGrid** 와 [TSTL](https://github.com/samchon/tstl) 을 추천합니다. "*Low Performance* 따위, [1. Strengths](#1-strengths) 앞에 티끌과도 같은 존재이며, 그 조차도 *부분 최적화*로 해소할 수 있다" 같은 말씀을 드리려는 게 아닙니다.

[Grid Computing](../tutorial/concepts.md#11-grid-computing) 시스템을 처음부터 C++ 같은 네이티브 언어로 설계하고 만드는 것은 매우 어려운 일입니다. 난이도 뿐 아니라 안정성을 담보하기도 어렵고, 그 개발 기간은 무한정 길어질 뿐입니다. 만일 만들고자 하시는 게 정말로 초대형 연산작업을 분할처리하기 위한 것이라면, 그 때의 난이도는 [블록체인의 Network System, 지옥으로의 발걸음](blockchain.md#steps-to-hell) 따위는 우스울 정도로 치솟아버립니다.

그래서 저는 권합니다. 우선 **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 이용하여 빠르고 쉽게, 그리고 안정적으로 개발하십시오. Business Logic 에 집중하여 빠르게 서비스를 진행하십시오. 서비스가 안정적으로 구동되는 게 확인되거든, 그 때 가서 *Full Migration* 을 진행하십시오. 이미 완성된 시스템과 안정화된 서비스가 있으니, 단지 이를 C++ 등의 문법에 맞게 옮겨적으시기만 하면 됩니다. 

제 경험상, 네이티브 언어로 만드는 [Grid Computing](../tutorial/concepts.md#11-grid-computing) 시스템은 이렇게 개발하는게 훨씬 더 효율적입니다. 이렇게 개발해보니 개발 기간은 훨씬 더 단축되었고, 시스템은 훨씬 더 안정적이었습니다. 물론, **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 를 사용해 서비스를 먼저 만들고보니, 예상 외로 *performance* 이슈가 없거나 혹은 [부분 최적화](#222-partial-optimization)만으로 해소될 수 있다거나 할 수도 있습니다. 그럼 그 때는 "휴~ 정말 다행이다" 라고 말해야 하는 걸까요?

### 2.3. Low Background
만든 지 얼마 안 되어 저변이 얕습니다.

> 노오력하여 반드시 극복하도록 하겠습니다. 많이 도와주십시오.

**TGrid** 는 이제 막 만들어진 신생 프레임워크입니다. 따라서 그것이 주창하는 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 이 제 아무리 그럴싸하고 획기적이더라도, 이를 사용하여 만든 프로젝트의 수는 극히 적습니다. 기껏해야 제가 만든 [예제 프로젝트들](../tutorial/projects)이나, 혹은 제가 개발하여 적용한 일부 상용 프로젝트들에 불과할 뿐입니다. 따라서 **TGrid** 에 관한 정보와 노하우를 세간에 공유할 수 있는 창구도 별로 없습니다.

가령 [블록체인](blockchain.md) 프로젝트를 예로 든다면, 제 아무리 **TGrid** 를 사용하여 블록체인을 쉽게 개발할 수 있다한들, 이미 기존의 블록체인 프로젝트들은 다 기존의 방법대로 개발이 되어있지 않습니까? 블록체인을 개발함에 있어 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 이용해 만드는 게 쉬울지, 아니면 기존의 프로젝트를 참고하고 개발자 커뮤니티와 그들의 노하우를 전수받는게 쉬울지는 모를 일입니다

> 단 아예 새로운 종류의 비지니스 로직을 가진 블록체인이라면, 그 때는 자신있게 **TGrid** 가 훨씬 쉽다고 말할 수 있습니다.

뭐 제 스스로도 암담하게 느껴지는 바이나, 현재의 현실이 이러합니다. **TGrid** 가 만든 지 얼마 안 되어 저변이 얕은 것은 주지의 사실이며 달리 해결책도 없습니다. 그저 오랜 시간을 들여 꾸준히 노력하는 수밖에 없다고 생각합니다. 그래도 저는 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 이 곧 네트워크 시스템 개발의 대세가 될 거라 믿어 의심치 않습니다. 저는 이 것이 미래라 믿고 앞으로 달려나갈테니, 여러분도 많이 도와주십시오. 

시간이 지나면 언젠가, **TGrid** 도 유명해지는 날이 오겠죠. 어쩌면 그리 오래 안 걸릴 수도 있구요.




## 3. Opportunities
### 3.1. Block Chain
> 자세한 내용: [**Appendix** > **Blockchain**](blockchain.md)

**TGrid** 를 이용하면, 블록체인 프로젝트를 보다 쉽게 개발할 수 있습니다.

블록체인 프로젝트의 개발 난이도가 높다는 것은 매우 유명한 이야기입니다. 구태여 블록체인 개발자들의 몸값이 다락같이 높아서 그런 것만이 아닙니다. 순 기술적인 관점에서 보더라도, 블록체인은 그 자체로 난이도가 매우 높습니다. 단, 기술적으로 무엇이 그렇게 어렵냐고 물었을 때, 저는 이렇게 말하고 싶습니다. 진정 어려운 것은 [Network System](blockchain.md#3-network-system) 때문이지, [Business Logic](blockchain.md#2-business-logic) 때문은 아니라고 말입니다.

블록체인이 사용하는 [Network System](blockchain.md#3-network-system) 은, 기본적으로 수 만 ~ 수십 만 대의 컴퓨터가 네트워크 통신으로 어우러져 연동되는, 초대형 분산처리 시스템입니다. 그리고 이런 종류의 초대형 분산처리 시스템들은 하나같이, 어마무시한 난이도를 자랑합니다. 이를 개발하는 모든 과정에 '완벽' 이라는 무시무시한 수식어가 따라다닙니다. 완벽한 요구사항 분석, 완벽한 유즈케이스 도출, 완벽한 개념 설계와 데이터 구조 정립, 완벽한 네트워크 아키텍처 수립, 완벽한 구현과 모든 케이스를 아우르는 완벽한 테스트 프로그램 제작 등...

반면에 블록체인의 [Business Logic](blockchain.md#2-business-logic) 은 그렇게까지 어렵지 않습니다. 블록체인의 핵심 요소를 말하라 그러면, 그 이름 그대로 "첫째는 Block 이요, Chain 입니다" 라고 대답할 수 있습니다. 이 중 Block 은 어떤 데이터를 다루냐에 관한 것이고, Chain 은 블록에 데이터를 기록함에 있어 '상호간 어떻게 합의할까' 같은 정책에 관한 것입니다.

 Component | Conception     | Description
-----------|----------------|------------------
 Block     | Data Structure | 데이터를 저장하는 방법
 Chain     | Requirements   | 합의 도출에 관한 정책

만일 이 Block 과 Chain 을 단 한대의 컴퓨터에서 동작하는 단일 프로그램으로 개발한다고 생각해봅시다. 이 경우에는 그저 자료구조를 설계하여 이를 디스크에 저장할 수 있고, 정책 (요구사항) 을 분석하여 코드로 구현할 수만 있으면 됩니다. 소양있는 개발자라면 누구나 만들 수 있는 것, 그것이 바로 블록체인의 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 입니다. 여러분도 얼마든지 해내실 수 있습니다.

그리고 **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 이용하면, 진정한 [Grid Computing](../tutorial/concepts.md#11-grid-computing) 을 실현할 수 있습니다. 네트워크로 연동된 여러 대의 컴퓨터들은 단 하나의 가상 컴퓨터로 치환됩니다. 그리고 이렇게 만든 <u>가상 컴퓨터</u>에서 동작하는 코드는, 실제 단 한 대의 컴퓨터에서 동작하는 프로그램과 그 [Business Logic](blockchain.md#3-network-system) 코드가 동일합니다.

따라서 **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 사용하면, 블록체인 프로젝트의 개발 난이도는 Network System 이 아닌 [Business Logic](blockchain.md#3-network-system) 수준으로 확 떨어집니다. 여러분께서는 복잡한 [Network System](blockchain.md#3-network-system) 따위 잊어버리시고, 그저 여러분이 만들고자 하시는 것의 본질, [Business Logic](blockchain.md#2-business-logic) 그 자체에만 집중하십시오.

### 3.2. Public Grid
> 관련 프로젝트: [**Tutorial** > **Projects** > **Grid Market**](../tutorial/projects/market.md)

**TGrid** 를 사용하면, [Grid Computing](../tutorial/concepts.md#11-grid-computing) 에 필요한 자원을 불특정 다수로부터 매우 쉽게, 그리고 저렴하게 조달할 수 있습니다.

[Grid Computing](../tutorial/concepts.md#11-grid-computing) 을 구성할 때는 당연하게도 여러 대의 컴퓨터가 필요합니다. 이 때 필요한 컴퓨터 대수가 많아지면 많아질수록, 이를 조달하기 위해 갖춰야 하는 인프라와 제반 비용도 덩달아 올라가기 시작합니다. 게다가 이렇게 조달한 각 컴퓨터에 일일히 필요한 프로그램을 설치하고, 네트워크 통신을 위한 다양한 설정을 해야 하는 등, 그 수고로움 또한 무던히 증가하게 됩니다. 뭐 너무나도 당연한 얘기인가요?

Name | Consumer                          | Supplier
-----|-----------------------------------|-------------------------------
Who  | [Grid Computing](../tutorial/concepts.md#11-grid-computing) 시스템 제작 희망자      | 인터넷 접속이 가능한 불특정 다수
What | *Supplier* 의 자원을 가져다 씀           | *Consumer* 에게 자신의 자원을 제공함
How  | 각 *Supplier* 가 구동할 프로그램 코드 제공  | 인터넷 브라우저로 특정 URL 접속

하지만, **TGrid** 를 사용하면 이 비용과 수고조차도 획기적으로 줄일 수 있습니다. [Grid Computing](#12-grid-computing) 에 필요한 컴퓨터를 **불특정** 다수로부터 조달할 수 있으며, 이들 불특정 다수의 컴퓨터에는 그 무엇도 설치하거나 설정할 필요가 없습니다. 단지 이들이 인터넷에 연결되어있고, 브라우저를 실행하여 특정 URL 에 접속할 수만 있으면 됩니다.

각 *Supplier* 가 구동해야 할 프로그램은 *Consumer* 가 JavaScript 코드로써 제공합니다. 각 *Supplier* 는 *Consumer* 가 건네준 스크립트를 가동하여, (*Supplier* 가 정해준) 그들의 역할을 수행하게 될 것입니다. 물론 *Supplier* 와 *Consumer* 의 연동 (혹은 제 3 의 컴퓨터와의 연동) 에는 모두 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 가 사용될 것이니, 이들은 모두 하나의 가상 컴퓨터일 뿐입니다.

> **TGrid** 의 기반 언어인 TypeScript 의 컴파일 결과물은 JavaScript 파일이며, JavaScript 는 스크립트 언어이기에 동적 실행이 가능합니다. 따라서 *Consumer* 가 건네준 프로그램 코드를 Supplie 가 그대로 실행하는 것 또한 가능합니다.

![Grid Market](../../assets/images/projects/market/actors.png)

그리고 이러한 *Public Grid* 의 가장 전형적인 사례 중 하나가 바로, TGrid 에서 데모 프로젝트로 제공하는 [Grid Market](../tutorial/projects/market.md) 입니다. 이 데모 프로젝트에서도 *Consumer* 는 Grid Computing 시스템을 구성하기 위하여 *Supplier* 의 자원을 빌려다 쓰며, *Supplier* 는 인터넷 브라우저의 특정 URL 에 접속하는 것만으로도 *Consumer* 에게 자신의 자원을 제공할 수 있습니다. 
물론 [Grid Market](../tutorial/projects/market.md) 에서도 여전히, *Supplier* 가 실행할 프로그램은 *Consumer* 가 제공합니다.

다만, [Grid Market](../tutorial/projects/market.md) 에 특이사항이 하나 있다면, 그것은 바로 *Consumer* 가 *Supplier* 의 자원을 가져다 쓰는 데에 대가가 따른다는 것입니다. 더불어 중개시장 *Market* 이 존재하여, *Consumer* 와 *Supplier* 간의 매칭을 알선하고 그 대가로 일정 수수료를 징수합니다.

  - `Market`: 자원을 사고팔 수 있는 중개 시장
  - `Consumer`: *Supplier* 의 자원을 구매하여 이를 사용함
  - `Supplier`: *Consumer* 에게 자신의 자원을 제공함

### 3.3. Market Expansions
[Grid Computing](../tutorial/concepts.md#12-grid-computing) 에 관련된 시장은 나날이 성장해나갈 것입니다.

미래는 준비하는 자의 것입니다. **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#13-remote-function-call) 을 통하여, 다가오는 미래에 대비하시고, 나아가 한 몫 단단히 잡으시기를 바랍니다.




## 4. Threats
무엇이 **TGrid** 와 [Remote Function Call](../tutorial/concepts.md#12-remote-function-call) 을 위협할 수 있을까요? *'SWOT 분석'* 을 진행함에 있어서, 아직 이 부분은 딱히 떠오르는 아이디어가 없어 글을 쓰지 못했습니다. 혹여 떠오르시는 아이디어가 있거든, 부디 제보해주시기 바랍니다.

  - https://github.com/samchon/tgrid/issues