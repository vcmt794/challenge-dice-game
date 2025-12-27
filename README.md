# Dice Game – Rigged Randomness Challenge

Challenge này minh họa việc **randomness trên blockchain là xác định (deterministic)** và có thể bị khai thác nếu dùng sai cách (ví dụ: `blockhash`).

Mục tiêu của bạn là **tạo một contract tấn công**, dự đoán trước kết quả roll dice và **chỉ chơi khi chắc chắn thắng**.

---

## Yêu cầu môi trường

Cài sẵn các công cụ sau:

* Node.js **>= 20.18.3**
* Yarn (v1 hoặc v2+)
* Git

---

## Khởi tạo project

```bash
npx create-eth@1.0.2 -e challenge-dice-game challenge-dice-game
cd challenge-dice-game
yarn install
```

---

## Checkpoint 0 – Environment

### Terminal 1 – chạy local blockchain

```bash
yarn chain
```

### Terminal 2 – deploy contracts

```bash
yarn deploy
```

### Terminal 3 – chạy frontend

```bash
yarn start
```

Mở trình duyệt:

```
http://localhost:3000
```

---

## Checkpoint 1 – Dice Game

### Mục tiêu

* Hiểu cách `DiceGame.sol` tạo số ngẫu nhiên
* Xác định liệu có thể **dự đoán trước kết quả roll** hay không

### Việc cần làm

1. Mở file:

```
packages/hardhat/contracts/DiceGame.sol
```

2. Phân tích đoạn code tạo roll:

```solidity
bytes32 prevHash = blockhash(block.number - 1);
bytes32 hash = keccak256(abi.encodePacked(prevHash, address(this), nonce));
uint256 roll = uint256(hash) % 16;
```

### Kết luận

* `blockhash(block.number - 1)` → **đã biết khi tx chạy**
* `address(this)` → cố định
* `nonce` → public

**Có thể dự đoán chính xác roll**

---

## Checkpoint 2 – Rigged Contract

### Mục tiêu

* Viết contract `RiggedRoll.sol`
* Chỉ gọi `rollTheDice()` khi **roll ≤ 5**

### Việc cần làm

#### 1️⃣ Thêm `receive()` để nhận ETH

```solidity
receive() external payable {}
```

#### Viết `riggedRoll()`

* Đọc `nonce` từ DiceGame
* Tạo hash giống hệt DiceGame
* Nếu roll thắng → gọi `rollTheDice{value: 0.002 ether}()`

#### Deploy RiggedRoll

Mở file:

```
packages/hardhat/deploy/01_deploy_riggedRoll.ts
```

Uncomment phần deploy RiggedRoll, sau đó chạy:

```bash
yarn deploy --reset
```

#### Fund RiggedRoll

* Dùng **Faucet** trên UI
* Gửi ETH vào **địa chỉ RiggedRoll**

---

## Checkpoint 3 – Where’s my money?

### Vấn đề

* Prize được gửi về **RiggedRoll contract**
* Không phải ví frontend

### Giải pháp

Viết hàm `withdraw`

```solidity
function withdraw(address payable _to, uint256 _amount) external onlyOwner {
    (bool sent, ) = _to.call{value: _amount}("");
    require(sent, "Withdraw failed");
}
```

### Side Quest

* Dùng `Ownable`
* Chỉ owner mới được rút tiền

### Lưu ý

Trong file deploy:

```
01_deploy_riggedRoll.ts
```

→ set **frontend address** làm owner

---

## Checkpoint 4 – Deploy lên Sepolia

### 1️⃣ Tạo deployer wallet

```bash
yarn generate
yarn account
```

### 2️⃣ Lấy Sepolia ETH

Khuyên dùng faucet **không cần Mainnet ETH**:

```
https://sepolia-faucet.pk910.de
```

### 3️⃣ Deploy lên Sepolia

```bash
yarn deploy --network sepolia
```

---

## Checkpoint 5 – Deploy Frontend

### 1️⃣ Cấu hình network

File:

```
packages/nextjs/scaffold.config.ts
```

```ts
targetNetwork: chains.sepolia,
```

### 2️⃣ Deploy frontend

```bash
yarn vercel
```

Hoặc production:

```bash
yarn vercel --prod
```
Có được url:
```
https://nextjs-15g8e3rzb-lab01s-projects.vercel.app
```

---

## 📜 Checkpoint 6 – Verify Contract

```bash
yarn verify --network sepolia
```

* Copy link Etherscan
  ```
  https://sepolia.etherscan.io/address/0xA2076d856eDf7C9F8Ca310Cf72F270c1665dcf5F
  ```
* Submit lên **SpeedRunEthereum**

---

## Hoàn thành
