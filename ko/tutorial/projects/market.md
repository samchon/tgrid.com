# Grid Market
## 1. Outline
  - 데모 사이트: http://samchon.org/market
  - 코드 저장소: https://github.com/samchon/tgrid.projects.market

![Actors](../../../assets/images/projects/market/actors.png)

이번 단원에서는 Computing 자원을 거래할 수 있는 *Grid Market* 을 만들어봅니다.

Grid Computing 시스템을 구축하는 데 필요한 연산력을 매매할 수 있는 온라인 시장, Market 을 만듦니다. 그리고 그 시장에 참여하여 연산력을 거래하는 수요자 Consumer 와 공급자 Supplier 시스템을 각각 만들어봅니다. 마지막으로 시장에서 이루어지는 모든 매매행위를 들여다 볼 수 있는 Monitor 시스템을 만들 것입니다.

물론, 이 프로젝트는 **TGrid** 를 익히는 데 도움을 주기 위해 만든 데모 프로젝트로써, Market 에서 연산력을 사고 파는 데 실제로 돈이 오가지는 않습니다. 하지만, 연산력을 상호 매매한다는 개념 자체가 허구인 것은 아닙니다. Market 을 통하여 이루어지는 일련의 행위, Consumer 와 Supplier 간의 상호 연산력의 소비와 공급은, 모두 허구가 아닌 실제의 것이 될 것입니다.

  - `Market`: 연산력을 사고팔 수 있는 중개 시장
  - `Consumer`: *Supplier* 의 연산력을 구매하여 이를 사용함
  - `Supplier`: *Consumer* 에게 자신의 연산력을 제공함
  - `Monitor`: *Market* 에서 이루어지는 모든 거래행위를 들여다 봄




## 2. Design



## 3. Implementation
### 3.1. Market
#### [`core/market/Market.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/market/Market.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/market/Market.ts") -->
```

#### [`core/market/ConsumerChannel.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/market/ConsumerChannel.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/market/ConsumerChannel.ts") -->
```

#### [`core/market/SupplierChannel.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/market/SupplierChannel.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/market/SupplierChannel.ts") -->
```

### 3.2. Consumer
#### [`core/consumer/Servant.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/consumer/Servant.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/consumer/Servant.ts") -->
```

#### [`core/consumer/Consumer.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/consumer/Consumer.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/consumer/Consumer.ts") -->
```

### 3.3. Supplier
#### [`core/supplier/ISupplier.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/supplier/ISupplier.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/supplier/ISupplier.ts") -->
```

#### [`core/supplier/Supplier.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/supplier/Supplier.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/supplier/Supplier.ts") -->
```

### 3.4. Monitor
#### [`core/monitor/Monitor.ts](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/monitor/Monitor.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/monitor/Monitor.ts") -->
```

#### [`core/monitor/ConsumerNode.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/monitor/ConsumerNode.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/monitor/ConsumerNode.ts") -->
```

#### [`core/monitor/SupplierNode.ts`](https://github.com/samchon/tgrid.projects.market/blob/master/src/core/monitor/SupplierNode.ts)
```typescript
<!-- @import("https://raw.githubusercontent.com/samchon/tgrid.projects.market/master/src/core/monitor/SupplierNode.ts") -->
```