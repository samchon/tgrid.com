<!-- @templates([
    ["Provider", "[Provider](../concepts.md#22-provider)"],
    ["Driver", "[Driver](../concepts.md#23-driver)"],
    ["Controller", "[Controller](../concepts.md#24-controller)"],
    ["Market", "[Market](#121-market)"],
    ["Consumer", "[Consumer](#122-consumer)"],
    ["Supplier", "[Supplier](#123-supplier)"],
    ["Monitor", "[Monitor](#124-monitor)"]
]) -->

# Grid Market
## 1. Concepts
### 1.1. Outline
  - 데모 사이트: http://samchon.org/market
  - 코드 저장소: https://github.com/samchon/tgrid.projects.market

![Actors](../../../assets/images/projects/market/actors.png)

이번 단원에서는 Computing 자원을 거래할 수 있는 *Grid Market* 을 만들어봅니다.

Grid Computing 시스템을 구축하는 데 필요한 연산력을 매매할 수 있는 온라인 시장, Market 을 만듦니다. 그리고 그 시장에 참여하여 연산력을 거래하는 수요자 Consumer 와 공급자 Supplier 시스템을 각각 만들어봅니다. 마지막으로 시장에서 이루어지는 모든 매매행위를 들여다 볼 수 있는 Monitor 시스템을 만들 것입니다.

물론, 이 프로젝트는 **TGrid** 를 익히는 데 도움을 주기 위해 만든 데모 프로젝트로써, Market 에서 연산력을 사고 파는 데 실제로 돈이 오가지는 않습니다. 하지만, 연산력을 상호 매매한다는 개념 자체가 허구인 것은 아닙니다. Market 을 통하여 이루어지는 일련의 행위, Consumer 와 Supplier 간의 상호 연산력의 소비와 공급은, 모두 허구가 아닌 실제의 것이 될 것입니다.

  - ${{ Market }}: 연산력을 사고팔 수 있는 중개 시장
  - ${{ Consumer }}: *Supplier* 의 연산력을 구매하여 이를 사용함
  - ${{ Supplier }}: *Consumer* 에게 자신의 연산력을 제공함
  - ${{ Monitor }}: *Market* 에서 이루어지는 모든 거래행위를 들여다 봄

### 1.2. Participants
#### 1.2.1. Market
#### 1.2.2. Consumer
#### 1.2.3. Supplier
#### 1.2.4. Monitor

### 1.3. Strengths




## 2. Design
### 2.1. Considerations
### 2.2. Controllers
#### 2.2.1. Market
아래는 Market 이 Consumer 에게 제공할 기능들을 정의한 ${{ Controller }} 입니다.

Consumer 가 이 ${{ Controller }} 를 통해 할 수 있는 일은 크게 두 가지로 나눌 수 있습니다. 첫째는 바로 현재 Market 에 참여중인 Supplier 들이 누구인지 아는 것입니다 (`getSuppliers()`). 그리고 둘째는 그들의 자원을 구원을 구매하고 (`buyResource()`), 그것들을 사용하는 것입니다 (`assignees`).

```typescript
export namespace ConsumerChannel
{
    export interface IController
    {
        /**
         * 해당 *Consumer* 에게 배정된 *Supplier* 들의 `Controller` 리스트.
         */
        assignees: ArrayLike<Supplier.IController>;

        /**
         * Get 해당 *Consumer* 의 식별자 번호
         */
        getUID(): number;

        /**
         * Get *Market* 에 있는 전체 *Supplier* 들의 리스트
         */
        getSuppliers(): ISupplier[];

        /**
         * 대상 *Supplier* 의 자원을 구매함.
         * 
         * @param uid 대상 Supplier 의 식별자 번호 uid.
         * @return 성공 여부, 이미 다른 Consumer 에게 먼저 배정되었다면 false.
         */
        buyResource(uid: number): boolean;
    }
}
```

그리고 Market 이 Supplier 에 제공해주는 ${{ Provider }} 가 가진 객체는 딱 두가지 뿐입니다. 첫째는 해당 Supplier 에게 부여된 식별자 번호를 가져오는 함수이며, 둘째는 `provider` 변수로써, Consumer 를 기준으로는 Supplier 에게 제공하는 ${{ Provider }} 이고, Supplier 를 기준으로는 ${{ Driver }}<${{ Controller }}> 가 되겠죠.

  - Consumer: `WebConnector<Provider>.getProvider()`
  - Supplier: `WebConnector.getDriver<Controller>()`

```typescript
export namespace SupplierChannel
{
    export interface IController
    {
        /**
         * Consumer 에서 제공해주는 provider 객체
         */
        provider: object | null;

        /**
         * Get 해당 *Supplier* 의 식별자 번호
         */
        getUID(): number;
    }
}
```

#### 2.2.2. Consumer
Consumer 가 Market 에게 제공하는 ${{ Provider }} 는, Market 은 단지 중간 매개체로써 경유하기만 할 뿐, 실질적으로는 Supplier 들에게 제공되는 ${{ Provider }} 라고 보아도 무방합니다. 실제로 Supplier 는 Market 서버에 접속한 후, `Servant.IController` 에 정의된 `provider: object` 변수를 이용하여 Consumer 의 ${{ Provider }} 객체가 제공하는 함수들을 이용합니다.

```typescript
export namespace Consumer
{
    export interface IController
    {
        /**
         * 해당 Consumer 와 연결된 Supplier 들에게 제공할 provider 등의 리스트
         */
        servants: ArrayLike<Servant.IController>;
    }
}

export namespace Servant
{
    export interface IController
    {
        /**
         * Consumer 에서 제공해주는 provider
         */
        provider: object;

        /**
         * Consumer 와의 연결이 종료될 때까지 대기함
         */
        join(): void;

        /**
         * Consumer 와의 연결을 종료함
         */
        close(): void;
    }
}
```

#### 2.2.3. Supplier
Supplier 가 Market 에게 제공하는 ${{ Provider }} 는, Market 은 단지 중간 매개체로써 경유하기만 할 뿐, 실질적으로는 Consumer 에게 제공되는 ${{ Provider }} 라고 보아도 무방합니다. 실제로 Consumer 는 Market 서버에 접속한 후, `ConsumerChannel.IController` 에 정의된 `assignees: ArrayLike<Supplier.IController>` 변수를 이용하여 Supplier 의 ${{ Provider }} 객체가 제공하는 함수들을 이용합니다.

따라서 Supplier 가 Market (실질적으로는 Consumer) 에 제공하는 함수들에 인터페이스를 정의한 ${{ Controller }} 를 보시면, 모든 함수들의 초점이 바로 Consumer 에게 맞추어져있음을 알 수 있습니다. 제일 먼저 Supplier 에게 자원을 제공할 대상 Consumer 를 알려주는 `assign()` 함수가 있고, 둘째로 Consumer 가 건네주는 프로그램 소스코드를 컴파일하여 Worker 프로그램을 생성-가동하는 `compile()` 함수가 있습니다. 

그리고 마지막으로, `provider` 가 있습니다. 이것은, Supplier 가 Consumer 가 건네준 코드를 컴파일하여 생성한, Worker 프로그램에서 제공하는 ${{ Provider }} 를 사용할 수 있게 해 주는 변수입니다. Supplier 의 메인 프로그램이나 Consumer 프로그램의 기준에서는 ${{ Driver }}<${{ Controller }}> 에 해당합니다.

  - `WorkerServer<Provider>.getProvider()`
  - `WorkerConnector.getDriver<Controller>()`

```typescript
export namespace Supplier
{
    export interface IController
    {
        /**
         * 컴파일된 Worker 프로그램이 제공해주는 Provider.
         * 
         * *Supplier* 는 *Consumer* 가 제공해준 소스코드를 컴파일 ({@link compile}) 하여 
         * Worker 프로그램을 가동시킵니다. 객체 `provider` 는 바로 해당 Worker 프로그램이 제공하는
         * Provider (Supplier 메인 프로그램 기준으로는 Driver<Controller>) 를 의미합니다.
         * 
         *   - {@link WorkerServer.getProvider}
         *   - {@link WorkerConnector.getDriver}
         * 
         * @warning 반드시 {@link compile} 을 완료한 후에 사용할 것
         */
        provider: object;

        /**
         * 자원을 제공받을 *Consumer* 가 배정됨
         */
        assign(consumer_uid: number): void;

        /**
         * 소스코드를 컴파일하여 Worker 를 구동함
         * 
         * @param script 컴파일하여 구동할 Worker 프로그램의 소스코드
         * @param args 메인 함수 arguments
         */
        compile(script: string, ...args: string[]): void;

        /**
         * 구동 중인 Worker 를 종료함
         */
        close(): void;
    }
}
```

#### 2.2.4. Monitor
Monitor 는 Market 에게 ${{ Provider }} 를 하나 제공합니다. 이 ${{ Provider }} 가 설계된 목적은 단 하나로써, 이를 단 한 마디로 정의하자면 "Market 아, 너에게서 일어나는 모든 일을 나에게 알려줘" 입니다. 따라서 해당 ${{ Provider }} 에 대한 인터페이스 격인 ${{ Controller }} 에 정의된 함수 역시 모두, Market 에서 일어나는 일을 Monitor 에게 알려주기 위한 것들입니다.

Monitor 는 Market 에서 이루어지는, Consumer 와 Supplier 간의, 전체 거래를 들여다 볼 수 있습니다. 즉, Consumer 가 각 Supplier 의 자원을 구입할 때마다, Market 은 Monitor 에게 해당 거래에 대하여 알려줍니다; `transact()`. 또한, Consumer 가 모든 연산 작업을 마치고 자신이 구입했던 Supplier 들의 자원을 반환하는 순간 역시, Market 은 Monitor 에게 이를 알려줍니다; `release()`.

더불어 Monitor 는 현재 Market 에 참여하고 있는 Consumer 와 Supplier 의 전체 리스트를 알 수 있습니다. Monitor 가 처음 Market 서버에 접속하거든, Market 은 `assign()` 을 호출하여 전체 참여자 리스트를 Monitor 에게 전달합니다. 그리고 이후에 새로운 참여자가 들어오거나 나가거나 할 때마다, Market 은 관련 메소드 (`insertConsumer()` 나 `eraseSupplier()` 등) 를 호출하여, 이 사실을 Monitor 에게 전달하게 됩니다.

```typescript
export namespace Monitor
{
    export interface IController
    {
        /**
         * 시장 참여자 전체의 리스트를 할당
         * 
         * @param consumers 시장에 참여중인 *Consumer* 의 노드 리스트
         * @param suppliers 시장에 참여중인 *Supplier* 의 노드 리스트
         */
        assign(consumers: IConsumerNode[], suppliers: ISupplierNode[]): void;

        /**
         * *Conumser* 가 *Supplier* 의 자원을 구매하는 거래가 이루어짐
         * 
         * @param consumer 해당 *Consumer* 의 식별자 번호
         * @param supplier 해당 *Supplier* 의 식별자 번호
         */
        transact(consumer: number, supplier: number): void;

        /**
         * *Consumer* 가 모든 작업을 끝내고 구매하였던 자원을 반환함
         * 
         * @param consumer_uid 해당 *Consumer* 의 식별자 번호
         */
        release(consumer_uid: number): void;

        //----
        // INDIVIDUAL I/O
        //----
        /**
         * 신규 *Consumer* 의 입장
         * 
         * @param consumer *Consumer* 노드 정보
         */
        insertConsumer(consumer :IConsumerNode): void;

        /**
         * 신규 *Supplier* 의 입장
         *
         * @param supplier *Supplier* 노드 정보
         */
        insertSupplier(supplier: ISupplierNode): void;

        /**
         * 기존 *Consumer* 의 퇴장
         * 
         * @param uid 해당 *Consumer* 의 식별자 번호
         */
        eraseConsumer(uid: number): void;

        /**
         * 기존 *Supplier* 의 퇴장
         * 
         * @param uid 해당 *Supplier* 의 식별자 번호
         */
        eraseSupplier(uid: number): void;
    }
}
```

### 2.3. Architecture Design





## 3. Core Implementation
### 3.1. Market
Market 은 Consumer 와 Supplier 간의 컴퓨팅 자원 거래가 이루어지는 중개시장입니다. 

따라서 Market 클래스의 구현 코드는 제일 먼저 웹소켓 서버를 개설하는 것에서부터 시작합니다. 그리고 Market 서버에 클라이언트가 접속할 때마다, 해당 클라이언트가 접속에 사용한 주소를 기준으로 그 역할을 식별하고 전담 클래스를 생성하여 지원하게 됩니다.

 Path     | Role     | Generated Class
----------|----------|------------------
/consumer | Consumer | ConsummerChannel
/supplier | Supplier | SupplierChannel
/monitor  | Monitor  | MonitorChannel

#### [`core/market/Market.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/market/Market.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/market/Market.ts") -->
```

`ConsumerChannel` 은 Market 서버에 접속한 클라이언트 Consumer 에 대응하기 위한 클래스입니다. 

Market 서버 프로그램은 이 `ConsumerChannel` 클래스를 통하여 Consumer 가 구입한 Supplier 들의 자원 리스트를 기록하고 관리합니다. 그리고 Consumer 는 이 `ConsumerChannel` 클래스의 내부 네임스페이스에 정의된 `ConsumerChannel.Provider` 를 통하여, Market 서버에 접속해있는 전체 Supplier 들의 리스트를 열람하고, 그들의 자원을 구매하고 사용할 수 있습니다.

#### [`core/market/ConsumerChannel.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/market/ConsumerChannel.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/market/ConsumerChannel.ts") -->
```

`SupplierChannel` 은 Market 서버에 접속한 클라이언트 Supplier 에 대응하기 위한 클래스입니다. 

Market 서버 프로그램은 이 `SupplierChannel` 클래스를 통하여, 해당 Supplier 의 performance 정보를 기록하고 관리하며, 마찬가지로 해당 Supplier 의 자원을 구입한 Consumer 정보 역시 이 `SupplierChannel` 클래스에 기록됩니다. 

 Supplier 는 이 `SupplierChannel` 클래스의 내부 네임스페이스에 정의된 `SupplierChannel.Provider` 를 통하여, Consumer 가 자신에게 할당해 준 ${{ Provider }} 의 함수들을 ${{ Driver }}<${{ Controller }}> 를 통하여 원격 호출할 수 있습니다.

#### [`core/market/SupplierChannel.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/market/SupplierChannel.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/market/SupplierChannel.ts") -->
```

### 3.2. Consumer
`Consumer` 클래스는 Consumer 를 위하여 제작된 Facade 클래스입니다.

Consumer 는 `Consumer.participate()` 메서드를 이용하여 Market 서버에 접속함으로써, 시장에 참여할 수 있습니다. 그리고 `Consumer.getSuppliers()` 메서드를 이용하여 시장에 참여중인 전체 Supplier 들의 리스트를 조회할 수 있고, 이들 중 원하는 Supplier 들의 자원을 `Consumer.buyResource()` 메서드를 이용하여 구입할 수 있습니다.

#### [`core/consumer/Consumer.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/consumer/Consumer.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/consumer/Consumer.ts") -->
```

`Consumer.buyResource()` 를 통해 구입한 Supplier 의 자원은 `Servant` 클래스를 통하여 관리됩니다. 이 `Servant` 클래스의 역할은 Consumer 와 Supplier 의 Worker 프로그램을 잇는 Communicator 클래스입니다. 비록 Consumer 와 Supplier 의 Worker 프로그램 사이에는 Market 과 Supplier 의 메인 프로그램이 중간 매개체로써 자리하고 있더라도 말입니다.

Consumer 는 `Servant.compile()` 메서드를 통해 Supplier 에게 제공할 ${{ Provider }} 와, 그것이 실행해야 할 프로그램 소스코드를 건네줄 수 있습니다. 대상 Supplier 는 해당 프로그램 소스코드를 컴파일하고, 이를 새 Worker 프로그램에 탑재하여 구동하게 됩니다. 그리고 그 Worker 프로그램이 바로, 현 Consumer 프로그램과 연동하게 될 최종 인스턴스입니다.

#### [`core/consumer/Servant.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/consumer/Servant.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/consumer/Servant.ts") -->
```

### 3.3. Supplier
`Supplier` 클래스는 Supplier 를 위해 만들어진 Facade Controller 입니다.

Supplier 는 `Supplier.participate()` 메서드를 호출하여 Market 서버에 접속함으로써, 시장에 참여할 수 있습니다. 그리고 Supplier 클래스의 내부 네임스페이스에 정의된 `Supplier.Provider` 를 이용하여, Market 과 Consumer 가 필요로 하는 기능들을 제공하고 있습니다.

#### [`core/supplier/Supplier.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/supplier/Supplier.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/supplier/Supplier.ts") -->
```

또한, Supplier 의 식별자 및 performance 에 대한 정보는, 아래 `ISupplier` 구조체로 요약될 수 있습니다. Consumer 는 이 `ISupplier` 에 기재된 Supplier 의 요약정보를 보고, 해당 Supplier 의 자원 구매 여부를 결정하게 됩니다.

#### [`core/supplier/ISupplier.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/supplier/ISupplier.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/supplier/ISupplier.ts") -->
```

### 3.4. Monitor
`Monitor` 클래스는 Monitor 를 위해 만들어진 Facade Controller 입니다.

Monitor 는 `Monitor.participate()` 메서드를 호출하여 Market 서버에 접속합니다. 그리고 `Monitor` 클래스의 내부 네임스페이스에 정의된 `Monitor.Provider` 클래스와 `Monitor` 클래스의 다양한 accessor 메서드들을 이용하여, 시장에서 발생하는 모든 거래내역을 실시간으로 들여다볼 수 있습니다.

반대로 얘기하면, Market 은 시장에서 참여자 리스트에 변동이 생기거나 새로운 거래내역이 발생할 때마다, ${{ Driver }}<Monitor.IController> 의 함수들을 원격 호출하여 이를 Monitor 에게 알려줍니다.

#### [`core/monitor/Monitor.ts](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/monitor/Monitor.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/monitor/Monitor.ts") -->
```

`ConsumerNode` 클래스는 Market 에 참여한 Consumer 를 표현하기 위해 제작된 클래스로써, 해당 Consumer 구매한 Supplier 의 자원 내역을 기록하고 있습니다.

#### [`core/monitor/ConsumerNode.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/monitor/ConsumerNode.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/monitor/ConsumerNode.ts") -->
```

`SupplierNode` 클래스는 Market 에 참여한 Supplier 를 표현하기 위해 설계된 클래스로써, 해당 Supplier 의 자원을 구매하여 사용하고 있는 Consumer 에 대한 정보 또한 기록하고 있습니다.

#### [`core/monitor/SupplierNode.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/monitor/SupplierNode.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/monitor/SupplierNode.ts") -->
```