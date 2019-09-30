# Tutorial Projects
## [1. Chat Application](chat.md)
> - 데모 사이트: http://samchon.org/chat
> - 코드 저장소: https://github.com/samchon/tgrid.projects.chat

![Chat Application](../../../assets/images/projects/chat/chat-movie.png)

간단한 채팅 어플리케이션을 만들어봅니다.

네트워크 프로그래밍의 첫 예제 프로젝트는 거진 다 실시간 채팅 어플리케이션부터 시작하더군요. 저희도 바로 그 실시간 채팅 어플리케이션에서부터 시작합니다. 첫 예제 프로젝트 [Chat Application](chat.md) 는 매우 쉬우며 간소합니다. 저희가 만들 서버에는 오로지 단 하나의 채팅방만이 존재할 것이며, 모든 참여자 (클라이언트) 들은 이 곳에서 서로 대화하게 될 것입니다.




## [2. Othello Game](othello.md)
온라인 오델로 게임을 만들어봅니다.

단, 이번 예제 프로젝트에서는 단순히 오델로만 둘 수 있는 간단한 게임을 만들지는 않을 것입니다. 이전의 [1. Chat Application](#1-chat-application) 때와는 달리 난이도는 약간 더 높여서, 복수의 대진방이 존재할 것입니다. 게임 플레이어들은 각 대진방에 참여하여 직접 대국을 둘 수도 있고, 다른 플레이어들의 대국을 관람할 수도 있으며, 상호간 채팅도 할 수 있습니다.

  - 복수의 대진방 존재
    - 게임 플레이어로 참여 가능
    - 관전자로 참여 가능
    - 상호간 채팅 가능




## [3. Grid Market](market.md)
> - 데모 사이트: http://samchon.org/market
> - 코드 저장소: https://github.com/samchon/tgrid.projects.market

![Actors](../../../assets/images/projects/market/actors.png)

Grid Computing 시스템을 구축하는 데 필요한 연산력을 매매할 수 있는 온라인 시장, Market 을 만듦니다. 그리고 그 시장에 참여하여 연산력을 거래하는 수요자 Consumer 와 공급자 Supplier 시스템을 각각 만들어봅니다. 마지막으로 시장에서 이루어지는 모든 매매행위를 들여다 볼 수 있는 Monitor 시스템을 만들 것입니다.

물론, 이 프로젝트는 **TGrid** 를 익히는 데 도움을 주기 위해 만든 데모 프로젝트로써, Market 에서 연산력을 사고 파는 데 실제로 돈이 오가지는 않습니다. 하지만, 연산력을 상호 매매한다는 개념 자체가 허구인 것은 아닙니다. Market 을 통하여 이루어지는 일련의 행위, Consumer 와 Supplier 간의 상호 연산력의 소비와 공급은, 모두 허구가 아닌 실제의 것이 될 것입니다.

  - `Market`: 연산력을 사고팔 수 있는 중개 시장
  - `Consumer`: *Supplier* 의 연산력을 구매하여 이를 사용함
  - `Supplier`: *Consumer* 에게 자신의 연산력을 제공함
  - `Monitor`: *Market* 에서 이루어지는 모든 거래행위를 들여다 봄