# Introduction
## 1. Outline
### 1.1. TGrid
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/samchon/tgrid/blob/master/LICENSE)
[![npm version](https://badge.fury.io/js/tgrid.svg)](https://www.npmjs.com/package/tgrid)
[![Downloads](https://img.shields.io/npm/dm/tgrid.svg)](https://www.npmjs.com/package/tgrid)
[![Build Status](https://travis-ci.org/samchon/tgrid.svg?branch=master)](https://travis-ci.org/samchon/tgrid)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fsamchon%2Ftgrid.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fsamchon%2Ftgrid?ref=badge_shield)
[![Chat on Gitter](https://badges.gitter.im/samchon/tgrid.svg)](https://gitter.im/samchon/tgrid?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

> ```bash
> npm install --save tgrid
> ```

**TGrid** 의 풀네임은 TypeScript Grid Computing Framework 입니다.

**TGrid** 는 그 이름 그대로, TypeScript 에서 [Grid Computing](#12-grid-computing) 시스템을 구현하는 데 유용하게 사용할 수 있는 Framework 입니다. **TGrid** 와 그것의 핵심 개념인 [Remote Function Call](#13-remote-function-call) 차용하시거든, 여러분께서는 여러 대의 컴퓨터를 <u>단 한 대의 가상 컴퓨터</u>로 만드실 수 있습니다. 그것이 비록 수천 ~ 수만 대에 달할 지라도 말입니다.

여타 **TGrid** 에 대한 자세한 내용은 아래 링크들을 참고해주세요. 특히 아래 링크 중에서 [가이드 문서](https://tgrid.dev/korean) 의 [Basic Concepts](https://tgrid.dev/korean/tutorial/concepts.html) 나 [Learn from Examples](https://tgrid.dev/korean/tutorial/examples.html) 단원만큼은, **TGrid** 를 처음 접하시는 분이시라면, 꼭 한 번 읽어보시기를 권해드립니다.

  - Repositories
    - [GitHub Repository](https://github.com/samchon/tgrid)
    - [NPM Repository](https://www.npmjs.com/package/tgrid)
  - Documents
    - [API Documents](https://tgrid.dev/api)
    - [**Guide Documents**](https://tgrid.dev)
      - [English](https://tgrid.dev/english)
      - [한국어](https://tgrid.dev/korean)
    - [Release Notes](https://github.com/samchon/tgrid/releases)

### 1.2. Grid Computing
<img src="../assets/images/concepts/grid-computing.png" style="max-width: 563.4px" />

> Computers be a (virtual) computer

**TGrid** 는 그 이름 그대로, TypeScript 에서 [Grid Computing](#12-grid-computing) 시스템을 구현하는 데 유용하게 사용할 수 있는 Framework 입니다. 단, **TGrid** 가 말하는 `Grid Computing` 이란, 단순히 여러 대의 컴퓨터를 네트워크 통신을 이용하여 공통된 작업을 분산처리하는 것이 아닙니다. **TGrid** 가 말하는 진정한 `Grid Computing` 이란, 여러 대의 컴퓨터를 묶어 한 대의 가상 컴퓨터로 만들어내는 것입니다.

따라서 **TGrid** 기준에서의 `Grid Computing` 시스템이란, 그것을 구성하는 컴퓨터가 수백만 대라도, 처음부터 단 한대의 컴퓨터만 있었던 것인냥 개발할 수 있어야 합니다. 단 <u>한 대</u>에서 컴퓨터에서 동작하는 프로그램과, <u>수백만 대</u>를 이용한 분산병렬처리시스템이 모두 <u>동일한 프로그램 코드</u>를 사용할 수 있어야, 그것이 바로 진정 `Grid Computing` 입니다.

여러분도 그렇게 생각하시나요?

### 1.3. Remote Function Call
**TGrid** 가 [Grid Computing](#12-grid-computing) 을 실현하는 방법이란, 바로 `Remote Function Call` 로써, 문자 그대로 원격 시스템의 함수를 호출할 수 있다는 의미입니다. `Remote Function Call` 을 이용하면 여러분은 원격 시스템이 가진 객체를 마치 내 메모리 객체인 양 사용하실 수 있습니다.

**TGrid** 와 `Remote Function Call` 을 이용하면 원격 시스템의 객체와 함수를 마치 내 것인양 사용할 수 있다, 이 문장이 무엇을 의미할까요? 맞습니다, 원격 시스템의 객체와 함수를 직접 호출할 수 있다는 것은 곧, 현 시스템과 원격 시스템이 <u>하나의 가상 컴퓨터로 통합</u>되었다는 것을 의미합니다. 하나의 컴퓨터에 탑재된 <u>단일 프로그램</u>이니까, 객체간 함수도 호출할 수 있고 뭐 그런 것 아니겠습니까? 

하지만 **TGrid** 가 말하는 진정한 [Grid Computing](#12-grid-computing) 이 무슨 개념이니, `Remote Function Call` 이 어떤 이론이니... 백날 설명만 들어봐야 뭐합니까? 백문이 불여일견, 이쯤에서 실제 프로그램 코드를 한 번 봐야겠죠? 아래 예제 코드에 대하여 보다 자세히 알아보고 싶으시다면, [가이드 문서](https://tgrid.dev/korean) 의 [Learn from Examples](https://tgrid.dev/korean/tutorial/examples.html) 단원을 참고해주세요.

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




## 2. Strengths
### 2.1. Easy Development
누구나 쉽게 네트워크 연동시스템을 만들 수 있습니다.

### 2.2. Flexible Structure
네트워크 시스템에의 중대 변화도 매우 유연하게 대처할 수 있습니다.

![Diagram of Composite Calculator](../assets/images/examples/composite-calculator.png) | ![Diagram of Hierarchical Calculator](../assets/images/examples/hierarchical-calculator.png)
:-------------------:|:-----------------------:
Composite Calculator | Hierarchical Calculator

### 2.3. Safe Implementation
컴파일과 타입 검사를 통해 안전한 네트워크 시스템을 만들 수 있습니다.




## 3. Block Chain
**TGrid** 를 이용하면, 누구나 쉽게 블록체인 프로젝트를 개발할 수 있습니다.

본래 블록체인으로 무언가를 새로이 개발한다는 것은 매우 어려운 일입니다. 구태여 블록체인 개발자들의 몸값이 다락같이 높아서 그런 것만은 아닙니다. 순 기술적인 관점에서 보더라도, 블록체인은 그 자체로 난이도가 제법 높습니다. 단, 기술적으로 무엇이 그렇게 어렵냐고 물었을 때, 저는 이렇게 말하고 싶습니다.

> 블록체인이 유독 개발하기 어려운 것은, 그것의 네트워크 시스템을 구성하는 게 까다롭기 때문이지, 결코 블록체인의 Business Logic 이 복잡해서 그런 것은 아닙니다. 블록체인의 핵심 요소들은 여러분이 생각하시는 것보다 훨씬 간단하며, 이를 만드는 것 또한 그리 어렵지 않습니다.

### 3.1. Business Logic
블록체인의 핵심 요소들은 생각보다 간단하며 이를 구현하는 것 또한 쉽습니다.

블록체인의 핵심 요소라 그러면, 첫째로 '블록' 을 들 수 있습니다. 바로 어떤 데이터를 어떻게 저장하냐에 관한 문제입니다. 그리고 둘째는 '체인' 으로써, '블록' 에 데이터를 기록할 때 이를 어떻게 합의할까에 대한 정책적인 문제입니다. 블록체인 업계에서 흔히 말하는 탈중앙화니 암호화폐니 하는 것들은 결국, 모두 이 '블록' 과 '체인' 의 범주를 벗어나지 않습니다.

 Component | Conception     | Description
-----------|----------------|------------------
 Block     | Data Structure | 데이터를 저장하는 방법
 Chain     | Requirements   | 합의 도출에 관한 정책

만일 이 '블록' 과 '체인' 을 분산처리 네트워크 시스템이 아닌, 단 한 대의 컴퓨터에서 동작하는 단일 프로그램으로 개발한다고 가정해봅시다. 이 경우엔 그저 자료구조를 설계하여 이를 디스크에 저장할 수 있고, 정책 (요구사항) 을 분석하여 코드로 구현할 수만 있으면 됩니다.

즉, 블록체인의 Business Logic 그 자체는, 소양 있는 개발자라면 누구나 만들 수 있는 정도의 것입니다.

### 3.2. Network System
블록체인을 개발하면서 진정 어려운 것은, 네트워크 통신을 이용한 분산처리 시스템을 구현하는 것입니다.

블록체인의 [Business Logic](#31-business-logic) 제 아무리 쉬워봐야, 그것은 어디까지나 단 한 대의 컴퓨터에서 동작하는 단일 프로그램을 기준으로 했을 때의 이야기입니다. 실제의 블록체인 프로젝트들은, 기본적으로 수 만 ~ 수십 만 대의 컴퓨터가 네트워크 통신으로 어우러져 연동되는, 초대형 분산처리 시스템입니다.

그리고 이런 종류의 초대형 분산처리 시스템들은 하나같이, 어마무시한 준비 과정을 필요로 합니다. 모든 요구사항을 단 하나도 빠짐없이 철저히 도출해야 하며, 네트워크 시스템 아키텍처는 모든 유즈케이스에 대하여 단 하나의 헛점도 없이 완벽하게 설계해야 합니다. 모든 요구사항을 도출하고 완벽한 아키텍처를 정립한 끝에라야 비로소 프로그램 코드를 작성할 수 있는데, 이 과정 또한 결코 만만치 않습니다.

> #### 1 Requirements
> 종래의 방법으로 블록체인을 개발하려거든, 아주 뛰어난 아키텍트부터 구해야 합니다.
> 
> 이 아키텍트는 제일 먼저, 새로 만들고자 하는 블록체인에 대한 모든 요구사항을 완벽히 수집하여 이를 문서로써 정리하여야 합니다. 만일 새 블록체인에 대한 요구사항 중 제대로 인지하지 못한 게 있다거나, 나중에 요구사항이 변하는 일이 생기면 모든 과정을 처음부터 다시 시작해야 합니다. 따라서 요구사항 분석은 매우 꼼꼼하게 세밀하게 이루어져야 합니다.
> 
> #### 2 Analyses
> 수집한 요구사항을 분석하여, 모든 비지니스 로직을 완벽하게 발굴해야 합니다.
> 
> 그리고 확정한 요구사항과 유즈케이스에 맞추어, 개념 설계도를 새로이 작성합니다. 만약 이전에 행하였던 요구사항 분석에 미진함이 있거나 모순점이 있거든, 다시 1 번의 과정으로 돌아가서 처음부터 다시 시작해야합니다.
> 
> #### 3 Designs
> #### 4 Implementations
> #### 5 Conservations

### 3.3. Conclusion
여태까지의 이야기를 정리하면, '블록체인은 [Business Logic](#31-business-logic) 은 간단하지만, 그것의 [Network System](#32-network-system) 을 구성하는 것은 매우 어렵다' 라고 요약할 수 있습니다. 그리고 여기서, 우리는 한 가지 대목에 주목해 볼 필요가 있습니다. 그것은 바로 '블록체인의 [Business Logic](#31-business-logic) 은 간단하다' 라는 것입니다.

기억하십니까? **TGrid** 와 [Remote Function Call](#13-remote-function-call) 을 이용하면, 여러 대의 컴퓨터를 [한 대의 가상 컴퓨터](#12-grid-computing) 로 만들 수 있습니다. 그리고 이렇게 만든 가상 컴퓨터에서 동작하는 코드는, 실제로 단 한대의 컴퓨터에서 동작하는 프로그램과 그 [Business Logic](#31-business-logic) 코드가 동일합니다. 이에 따라, 우리는 다음과 같은 결론을 도출해낼 수 있습니다.

  - 블록체인의 [Business Logic](#31-business-logic) 은 어렵지 않다.
  - **TGrid** 를 사용하면, [Business Logic](#31-business-logic) 에만 집중할 수 있다.
  - 따라서 **TGrid** 와 함께라면, 블록체인을 쉽게 만들 수 있다.