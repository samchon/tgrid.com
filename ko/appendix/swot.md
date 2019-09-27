# SWOT Analysis
<!-- @templates([
    ["chapter", "1"],
    ["assets", "../../assets/"],
    ["blockchain.md", "blockchain.md"],
    ["examples.md", "../tutorial/examples.md"],
    ["Grid Computing", "[Grid Computing](../tutorial/concepts.md#11-grid-computing)"],
    ["Remote Function Call", "[Remote Function Call](../tutorial/concepts.md#12-remote-function-call)"]
]) -->
<!-- @import("internal/strengths.md") -->




<!-- @templates([
    ["TSTL", "[TSTL](https://github.com/samchon/tstl)"]
]) -->
## 2. Weaknesses
### 2.1. High Traffic
네트워크 통신에서 범용성의 동의어는 오버헤드, 즉 트래픽 증가입니다.

> 하지만 트래픽 따위, 무시해도 좋습니다

TGrid 에서 ${{ Grid Computing }} 을 실현하기 위해 내세운 ${{ Remote Function Call }}, 우리는 이를 통하여 [1. Strengths](#1-strengths) 의 이점들을 누리고 있습니다. 하지만 빛이 있으면 어둠도 있는 법, ${{ Remote Function Call }} 을 실현핳기 위해 [Communicator](../tutorial/concepts.md#21-communicator) 가 네트워크 통신에 사용하는 데이터 구조는 JSON-string 으로써, 높은 범용성을 가지는 대신 데이터 전송량도 함께 늘어난다는 단점을 가지고 있습니다.

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
**TGrid** 의 풀네임은 TypeScript Grid Computing Framework 로써, 기반으로 삼고 있는 언어가 TypeScript 입니다. 그리고 TypeScript 의 컴파일 결과물은 JavaScript 이며, 당연하게도 스크립트 언어입니다. 그리고 프로그래머라면 누구나 다 알법한 사실이죠, 스크립트 언어는 네이티브 언어에 비해 느립니다. 따라서 **TGrid** 로 만든 ${{ Grid Computing }} 시스템은, 네이티브로 만든 것에 비해 느립니다.

때문에 우리는 ${{ Grid Computing }} 시스템을 만들 때, 한 가지 고민을 해 봐야 합니다. **TGrid** 와 ${{ Remote Function Call }} 을 사용해서 생기는 이점 [1. Strengths](#1-strengths) 가 스크립트 언어로 인하여 발생한 *Low Performance* 라는 약점을 충분히 상쇄할 수 있는지 아닌지.

물론, 여러분께서 만드시고자 하는 네트워크 시스템에 performance 이슈가 없거나, Grid Computing 시스템을 구현하고자 하는 이유가 초대형 연산을 분산하여 빠르게 처리하고자 함이 아니라 순전 비지니스 로직에 의함이라면 (대표적으로 블록체인), 이런 고민은 할 필요도 없겠죠? 이럴 때는 그냥 눈 딱 감고 **TGrid** 와 ${{ Remote Function Call }} 을 사용하세요.

![seesaw](../../assets/images/appendix/seesaw.gif)

#### 2.2.2. Partial Optimization
한 편, **TGrid** 가 이 *Low Performance* 이슈에 대하여, 아무런 대응전략도 없이 손을 놓은 것은 결코 아닙니다. *Low Performance* 그 자체로 인해 증대하는 인프라 비용은 [3.2. Publish Grid](#32-public-grid) 를 통해 상쇄할 수 있습니다 (추후 통계를 내 볼 것인데, 아마 비용이 단순히 상쇄되는 수준이 아니라 오히려 대폭 절감될 것이라고 예상합니다). 

그리고 *Low Performance* 그 자체도 나름대로 해소할 수 있는 방법이 있습니다. Performance Tuning 은 기대효과가 가장 큰 곳에서부터 시작하라고 하지 않습니까? 모든 프로그램 코드를 C++ 로 짤 필요는 없습니다. 기본적으로는 TypeScript 를 사용하여 만들되, 연산이 집중되는 구간들만을 네이티브 언어로 제작하여 연동하면 됩니다 (NodeJS 에서는 C++ 과의 직접적인 연동을 하면 되며, Web Browser 에서는 Web Assembly 와 연동하면 됩니다).

{% panel style="info", title="TypeScript Standard Template Library" %}

${{ TSTL }} 은 C++ 표준위원회가 정의한 STL (Standard Template Library) 을 TypeScript 로 구현한 모듈입니다. 만일 프로그램을 제작할 때 ${{ TSTL }} 를 사용하신다면, 그것은 C++ 의 표준 라이브러리와 동일한 자료구조, 동일한 인터페이스를 사용한다는 얘기와 똑같습니다. 따라서 ${{ TSTL }} 로 제작된 프로그램만큼, C++ 로 마이그레이션하기 수월한 게 또 없습니다.

만일 여러분께서 제작하고 계시는 프로그램에 performance 이슈가 생길 것 같다구요? 따라서 추후 C++ 로 마이그레이션해야 할 가능성이 있다구요? 그렇다면 일말의 주저함 없이 ${{ TSTL }} 을 사용하십시오. ${{ TSTL }} 은 여러분께 참으로 놀라운 경험을 선사할 것입니다.

{% endpanel %}

#### 2.2.3. Full Migration
설령 여러분께서 ${{ Grid Computing }} 시스템 전체를 C++ 로 만들고자 하시더라도, 저는 여전히 **TGrid** 와 ${{ TSTL }} 을 추천합니다. "*Low Performance* 따위, [1. Strengths](#1-strengths) 앞에 티끌과도 같은 존재이며, 그 조차도 *부분 최적화*로 해소할 수 있다" 같은 말씀을 드리려는 게 아닙니다.

${{ Grid Computing }} 시스템을 처음부터 C++ 같은 네이티브 언어로 설계하고 만드는 것은 매우 어려운 일입니다. 난이도 뿐 아니라 안정성을 담보하기도 어렵고, 그 개발 기간은 무한정 길어질 뿐입니다. 만일 만들고자 하시는 게 정말로 초대형 연산작업을 분할처리하기 위한 것이라면, 그 때의 난이도는 [블록체인의 Network System, 지옥으로의 발걸음](blockchain.md#steps-to-hell) 따위는 우스울 정도로 치솟아버립니다.

그래서 저는 권합니다. 우선 **TGrid** 와 ${{ Remote Function Call }} 을 이용하여 빠르고 쉽게, 그리고 안정적으로 개발하십시오. Business Logic 에 집중하여 빠르게 서비스를 진행하십시오. 서비스가 안정적으로 구동되는 게 확인되거든, 그 때 가서 *Full Migration* 을 진행하십시오. 이미 완성된 시스템과 안정화된 서비스가 있으니, 단지 이를 C++ 등의 문법에 맞게 옮겨적으시기만 하면 됩니다. 

제 경험상, 네이티브 언어로 만드는 ${{ Grid Computing }} 시스템은 이렇게 개발하는게 훨씬 더 효율적입니다. 이렇게 개발해보니 개발 기간은 훨씬 더 단축되었고, 시스템은 훨씬 더 안정적이었습니다. 물론, **TGrid** 와 ${{ Remote Function Call }} 를 사용해 서비스를 먼저 만들고보니, 예상 외로 *performance* 이슈가 없거나 혹은 [부분 최적화](#222-partial-optimization)만으로 해소될 수 있다거나 할 수도 있습니다. 그럼 그 때는 "휴~ 정말 다행이다" 라고 말해야 하는 걸까요?

### 2.3. Low Background
만든 지 얼마 안 되어 저변이 얕습니다.

> 노오력하여 반드시 극복하도록 하겠습니다. 많이 도와주십시오.

**TGrid** 는 이제 막 만들어진 신생 프레임워크입니다. 따라서 그것이 주창하는 ${{ Remote Function Call }} 이 제 아무리 그럴싸하고 획기적이더라도, 이를 사용하여 만든 프로젝트의 수는 극히 적습니다. 기껏해야 제가 만든 [예제 프로젝트들](../tutorial/projects)이나, 혹은 제가 개발하여 적용한 일부 상용 프로젝트들에 불과할 뿐입니다. 따라서 **TGrid** 에 관한 정보와 노하우를 세간에 공유할 수 있는 창구도 별로 없습니다.

가령 [블록체인](blockchain.md) 프로젝트를 예로 든다면, 제 아무리 **TGrid** 를 사용하여 블록체인을 쉽게 개발할 수 있다한들, 이미 기존의 블록체인 프로젝트들은 다 기존의 방법대로 개발이 되어있지 않습니까? 블록체인을 개발함에 있어 ${{ Remote Function Call }} 을 이용해 만드는 게 쉬울지, 아니면 기존의 프로젝트를 참고하고 개발자 커뮤니티와 그들의 노하우를 전수받는게 쉬울지는 모를 일입니다

> 단 아예 새로운 종류의 비지니스 로직을 가진 블록체인이라면, 그 때는 자신있게 **TGrid** 가 훨씬 쉽다고 말할 수 있습니다.

뭐 제 스스로도 암담하게 느껴지는 바이나, 현재의 현실이 이러합니다. **TGrid** 가 만든 지 얼마 안 되어 저변이 얕은 것은 주지의 사실이며 달리 해결책도 없습니다. 그저 오랜 시간을 들여 꾸준히 노력하는 수밖에 없다고 생각합니다. 그래도 저는 ${{ Remote Function Call }} 이 곧 네트워크 시스템 개발의 대세가 될 거라 믿어 의심치 않습니다. 저는 이 것이 미래라 믿고 앞으로 달려나갈테니, 여러분도 많이 도와주십시오. 

시간이 지나면 언젠가, **TGrid** 도 유명해지는 날이 오겠죠. 어쩌면 그리 오래 안 걸릴 수도 있구요.




<!-- @templates([
    ["market.md", "../tutorial/projects/market.md"]
]) -->
<!-- @import("internal/opportunities.md") -->




## 4. Threats
무엇이 **TGrid** 와 ${{ Remote Function Call }} 을 위협할 수 있을까요? *'SWOT 분석'* 을 진행함에 있어서, 아직 이 부분은 딱히 떠오르는 아이디어가 없어 글을 쓰지 못했습니다. 혹여 떠오르시는 아이디어가 있거든, 부디 제보해주시기 바랍니다.

  - https://github.com/samchon/tgrid/issues