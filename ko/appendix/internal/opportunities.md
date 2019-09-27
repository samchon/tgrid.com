<!-- 
must define those templates

  - assets
  - blockchain.md
  - market.md
  - Grid Computing
  - Remote Function Call

-->

## 3. Opportunities
### 3.1. Blockchain
> 자세한 내용: [**Appendix** > **Blockchain**](${{ blockchain.md }})

**TGrid** 를 이용하면, 블록체인 프로젝트를 보다 쉽게 개발할 수 있습니다.

블록체인 프로젝트의 개발 난이도가 높다는 것은 매우 유명한 이야기입니다. 구태여 블록체인 개발자들의 몸값이 다락같이 높아서 그런 것만이 아닙니다. 순 기술적인 관점에서 보더라도, 블록체인은 그 자체로 난이도가 매우 높습니다. 단, 기술적으로 무엇이 그렇게 어렵냐고 물었을 때, 저는 이렇게 말하고 싶습니다. 진정 어려운 것은 [Network System](${{ blockchain.md }}#2-network-system) 때문이지, [Business Logic](${{ blockchain.md }}#3-business-logic) 때문은 아니라고 말입니다.

블록체인이 사용하는 [Network System](${{ blockchain.md }}#2-network-system) 은, 기본적으로 수 만 ~ 수십 만 대의 컴퓨터가 네트워크 통신으로 어우러져 연동되는, 초대형 분산처리 시스템입니다. 그리고 이런 종류의 초대형 분산처리 시스템들은 하나같이, 어마무시한 난이도를 자랑합니다. 이를 개발하는 모든 과정에 '완벽' 이라는 무시무시한 수식어가 따라다닙니다. 완벽한 요구사항 분석, 완벽한 유즈케이스 도출, 완벽한 개념 설계와 데이터 구조 정립, 완벽한 네트워크 아키텍처 수립, 완벽한 구현과 모든 케이스를 아우르는 완벽한 테스트 프로그램 제작 등...

반면에 블록체인의 [Business Logic](${{ blockchain.md }}#3-business-logic) 은 그렇게까지 어렵지 않습니다. 블록체인의 핵심 요소를 말하라 그러면, 그 이름 그대로 "첫째는 Block 이요, Chain 입니다" 라고 대답할 수 있습니다. 이 중 Block 은 어떤 데이터를 다루냐에 관한 것이고, Chain 은 블록에 데이터를 기록함에 있어 '상호간 어떻게 합의할까' 같은 정책에 관한 것입니다. 

 Component | Conception     | Description
-----------|----------------|------------------
 Block     | Data Structure | 데이터를 저장하는 방법
 Chain     | Requirements   | 합의 도출에 관한 정책

만일 이 Block 과 Chain 을 단 한대의 컴퓨터에서 동작하는 단일 프로그램으로 개발한다고 생각해봅시다. 이 경우에는 그저 자료구조를 설계하여 이를 디스크에 저장할 수 있고, 정책 (요구사항) 을 분석하여 코드로 구현할 수만 있으면 됩니다. 소양있는 개발자라면 누구나 만들 수 있는 것, 그것이 바로 블록체인의 [Business Logic](${{ blockchain.md }}#3-business-logic) 입니다. 여러분도 얼마든지 해내실 수 있습니다.

그리고 **TGrid** 와 ${{ Remote Function Call }} 을 이용하면, 진정한 ${{ Grid Computing }} 을 실현할 수 있습니다. 네트워크로 연동된 여러 대의 컴퓨터들은 단 하나의 가상 컴퓨터로 치환됩니다. 그리고 이렇게 만든 <u>가상 컴퓨터</u>에서 동작하는 코드는, 실제 단 한 대의 컴퓨터에서 동작하는 프로그램과 그 [Business Logic](${{ blockchain.md }}#2-network-system) 코드가 동일합니다.

따라서 **TGrid** 와 ${{ Remote Function Call }} 을 사용하면, 블록체인 프로젝트의 개발 난이도는 Network System 이 아닌 [Business Logic](${{ blockchain.md }}#2-network-system) 수준으로 확 떨어집니다. 여러분께서는 복잡한 [Network System](${{ blockchain.md }}#2-network-system) 따위 잊어버리시고, 그저 여러분이 만들고자 하시는 것의 본질, [Business Logic](${{ blockchain.md }}#3-business-logic) 그 자체에만 집중하십시오.

### 3.2. Public Grid
> 관련 프로젝트: [**Tutorial** > **Projects** > **Grid Market**](${{ market.md }})

**TGrid** 를 사용하면, ${{ Grid Computing }} 에 필요한 자원을 불특정 다수로부터 매우 쉽게, 그리고 저렴하게 조달할 수 있습니다.

${{ Grid Computing }} 을 구성할 때는 당연하게도 여러 대의 컴퓨터가 필요합니다. 이 때 필요한 컴퓨터 대수가 많아지면 많아질수록, 이를 조달하기 위해 갖춰야 하는 인프라와 제반 비용도 덩달아 올라가기 시작합니다. 게다가 이렇게 조달한 각 컴퓨터에 일일히 필요한 프로그램을 설치하고, 네트워크 통신을 위한 다양한 설정을 해야 하는 등, 그 수고로움 또한 무던히 증가하게 됩니다. 뭐 너무나도 당연한 얘기인가요? 

Name | Consumer                          | Supplier
-----|-----------------------------------|-------------------------------
Who  | ${{ Grid Computing }} 시스템 제작 희망자      | 인터넷 접속이 가능한 불특정 다수
What | *Supplier* 의 자원을 가져다 씀           | *Consumer* 에게 자신의 자원을 제공함
How  | 각 *Supplier* 가 구동할 프로그램 코드 제공  | 인터넷 브라우저로 특정 URL 접속

하지만, **TGrid** 를 사용하면 이 비용과 수고조차도 획기적으로 줄일 수 있습니다. ${{ Grid Computing }} 에 필요한 컴퓨터를 **불특정** 다수로부터 조달할 수 있으며, 이들 불특정 다수의 컴퓨터에는 그 무엇도 설치하거나 설정할 필요가 없습니다. 단지 이들이 인터넷에 연결되어있고, 브라우저를 실행하여 특정 URL 에 접속할 수만 있으면 됩니다.

각 *Supplier* 가 구동해야 할 프로그램은 *Consumer* 가 JavaScript 코드로써 제공합니다. 각 *Supplier* 는 *Consumer* 가 건네준 스크립트를 가동하여, (*Supplier* 가 정해준) 그들의 역할을 수행하게 될 것입니다. 물론 *Supplier* 와 *Consumer* 의 연동 (혹은 제 3 의 컴퓨터와의 연동) 에는 모두 ${{ Remote Function Call }} 가 사용될 것이니, 이들은 모두 하나의 가상 컴퓨터일 뿐입니다.

> **TGrid** 의 기반 언어인 TypeScript 의 컴파일 결과물은 JavaScript 파일이며, JavaScript 는 스크립트 언어이기에 동적 실행이 가능합니다. 따라서 *Consumer* 가 건네준 프로그램 코드를 Supplie 가 그대로 실행하는 것 또한 가능합니다.

![Grid Market](../assets/images/projects/market/actors.png)

그리고 이러한 *Public Grid* 의 가장 전형적인 사례 중 하나가 바로, TGrid 에서 데모 프로젝트로 제공하는 [Grid Market](${{ market.md }}) 입니다. 이 데모 프로젝트에서도 *Consumer* 는 Grid Computing 시스템을 구성하기 위하여 *Supplier* 의 자원을 빌려다 쓰며, *Supplier* 는 인터넷 브라우저의 특정 URL 에 접속하는 것만으로도 *Consumer* 에게 자신의 자원을 제공할 수 있습니다. 
물론 [Grid Market](${{ market.md }}) 에서도 여전히, *Supplier* 가 실행할 프로그램은 *Consumer* 가 제공합니다.

다만, [Grid Market](${{ market.md }}) 에 특이사항이 하나 있다면, 그것은 바로 *Consumer* 가 *Supplier* 의 자원을 가져다 쓰는 데에 대가가 따른다는 것입니다. 더불어 중개시장 *Market* 이 존재하여, *Consumer* 와 *Supplier* 간의 매칭을 알선하고 그 대가로 일정 수수료를 징수합니다.

  - `Market`: 자원을 사고팔 수 있는 중개 시장
  - `Consumer`: *Supplier* 의 자원을 구매하여 이를 사용함
  - `Supplier`: *Consumer* 에게 자신의 자원을 제공함

### 3.3. Market Expansions
${{ Grid Computing }} 에 관련된 시장은 나날이 성장해나갈 것입니다. 

미래는 준비하는 자의 것입니다. **TGrid** 와 ${{ Remote Function Call }} 을 통하여, 다가오는 미래에 대비하시고, 나아가 한 몫 단단히 잡으시기를 바랍니다.