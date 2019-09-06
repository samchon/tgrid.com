# Basic Concepts
## 1. Outline
### 1.1. Grid Computing
### 1.2. Remote Function Call
### 1.3. Computers be a Computer




## 2. Components
### 2.1. Communicator
원격 시스템과의 네트워크 통신을 전담하는 객체입니다.

### 2.2. Provider
Object being provided for Remote System

*Provider* 는 원격 시스템에 제공할 객체입니다. 원격 시스템은 해당 시스템이 *Provider* 로 등록한 객체에 정의된 함수를 원격으로 호출할 수 있습니다.

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

*Controller* 는 원격 시스템에서 제공하는 [Provider](#22-provider) 에 대한 인터페이스입니다.

### 2.4. Driver
*Driver* of [Controller](#23-controller) for [RFC](#12-remote-function-call)

*Driver* 는 원격 시스템의 함수를 호출할 때 사용하는 객체입니다.




## 3. Protocols
### 3.1. Web Socket
### 3.2. Workers