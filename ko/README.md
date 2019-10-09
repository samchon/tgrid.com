<!-- @templates([
    [ "Grid Computing", "[Grid Computing](#12-grid-computing)" ],
    [ "Remote Function Call", "[Remote Function Call](#13-remote-function-call)" ]
]) -->

# Introduction
## 1. Outline
### 1.1. TGrid
![Slogan Flag](../assets/images/flag.png)

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/samchon/tgrid/blob/master/LICENSE)
[![npm version](https://badge.fury.io/js/tgrid.svg)](https://www.npmjs.com/package/tgrid)
[![Downloads](https://img.shields.io/npm/dm/tgrid.svg)](https://www.npmjs.com/package/tgrid)
[![Build Status](https://travis-ci.org/samchon/tgrid.svg?branch=master)](https://travis-ci.org/samchon/tgrid)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fsamchon%2Ftgrid.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fsamchon%2Ftgrid?ref=badge_shield)
[![Chat on Gitter](https://badges.gitter.im/samchon/tgrid.svg)](https://gitter.im/samchon/tgrid?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

**TGrid** 의 풀네임은 TypeScript Grid Computing Framework 입니다.

**TGrid** 는 그 이름 그대로, TypeScript 에서 ${{ Grid Computing }} 시스템을 구현하는 데 유용하게 사용할 수 있는 Framework 입니다. **TGrid** 와 그것의 핵심 개념인 ${{ Remote Function Call }} 을 사용하시거든, 여러분께서는 여러 대의 컴퓨터를 <u>단 한 대의 가상 컴퓨터</u>로 만드실 수 있습니다. 그것이 비록 수천 ~ 수만 대에 달할 지라도 말입니다.

여타 **TGrid** 에 대한 자세한 내용은 아래 링크들을 참고해주세요. 특히 아래 링크 중에서 [가이드 문서](https://tgrid.dev/ko) 의 [Basic Concepts](tutorial/concepts.md) 나 [Learn from Examples](tutorial/examples.md) 단원만큼은, **TGrid** 를 처음 접하시는 분이시라면, 꼭 한 번 읽어보시기를 권해드립니다.

  - Repositories
    - [GitHub Repository](https://github.com/samchon/tgrid)
    - [NPM Repository](https://www.npmjs.com/package/tgrid)
  - Documents
    - [API Documents](https://tgrid.dev/api)
    - [**Guide Documents**](https://tgrid.dev)
      - [English](https://tgrid.dev/en)
      - [한국어](https://tgrid.dev/ko)
    - [Release Notes](https://github.com/samchon/tgrid/releases)

### 1.2. Grid Computing
![Grid Computing](../assets/images/concepts/grid-computing.png)

> Computers be a (virtual) computer

**TGrid** 는 그 이름 그대로, TypeScript 에서 ${{ Grid Computing }} 시스템을 구현하는 데 유용하게 사용할 수 있는 Framework 입니다. 단, **TGrid** 가 말하는 `Grid Computing` 이란, 단순히 여러 대의 컴퓨터를 네트워크 통신을 이용하여 공통된 작업을 분산처리하는 것이 아닙니다. **TGrid** 가 말하는 진정한 `Grid Computing` 이란, 여러 대의 컴퓨터를 묶어 한 대의 가상 컴퓨터로 만들어내는 것입니다.

따라서 **TGrid** 기준에서의 `Grid Computing` 시스템이란, 그것을 구성하는 컴퓨터가 수백만 대라도, 처음부터 단 한대의 컴퓨터만 있었던 것인냥 개발할 수 있어야 합니다. 단 <u>한 대</u>에서 컴퓨터에서 동작하는 프로그램과, <u>수백만 대</u>를 이용한 분산병렬처리시스템이 모두 <u>동일한 프로그램 코드</u>를 사용할 수 있어야, 그것이 바로 진정 `Grid Computing` 입니다.

여러분도 그렇게 생각하시나요?

### 1.3. Remote Function Call
**TGrid** 가 ${{ Grid Computing }} 을 실현하는 방법이란, 바로 `Remote Function Call` 로써, 문자 그대로 원격 시스템의 함수를 호출할 수 있다는 의미입니다. `Remote Function Call` 을 이용하면 여러분은 원격 시스템이 가진 객체를 마치 내 메모리 객체인 양 사용하실 수 있습니다.

**TGrid** 와 `Remote Function Call` 을 이용하면 원격 시스템의 객체와 함수를 마치 내 것인양 사용할 수 있다, 이 문장이 무엇을 의미할까요? 맞습니다, 원격 시스템의 객체와 함수를 직접 호출할 수 있다는 것은 곧, 현 시스템과 원격 시스템이 <u>하나의 가상 컴퓨터로 통합</u>되었다는 것을 의미합니다. 하나의 컴퓨터에 탑재된 <u>단일 프로그램</u>이니까, 객체간 함수도 호출할 수 있고 뭐 그런 것 아니겠습니까? 

하지만 **TGrid** 가 말하는 진정한 ${{ Grid Computing }} 이 무슨 개념이니, `Remote Function Call` 이 어떤 이론이니... 백날 설명만 들어봐야 뭐합니까? 백문이 불여일견, 이쯤에서 실제 프로그램 코드를 한 번 봐야겠죠? 아래 예제 코드에 대하여 보다 자세히 알아보고 싶으시다면, [가이드 문서](https://tgrid.dev/ko) 의 [Learn from Examples](tutorial/examples.md) 단원을 참고해주세요.

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