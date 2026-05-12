# Docker 啟動指令

## 前置：建立自訂網路

```bash
docker network create goals-net
```

---

## 1. MongoDB

```bash
docker run \
  --name mongodb \
  --rm -d \
  -v data:/data/db \
  --network goals-net \
  -e MONGO_INITDB_ROOT_USERNAME=hh \
  -e MONGO_INITDB_ROOT_PASSWORD=secret \
  mongo
```

| 參數 | 說明 |
|------|------|
| `-v data:/data/db` | named volume，持久化資料庫資料 |
| `--network goals-net` | 加入自訂網路，讓 backend 可透過容器名稱解析 |
| `-e MONGO_INITDB_ROOT_*` | 設定 root 帳密 |

---

## 2. Backend (Node.js)

> 執行前先 build image：`docker build -t goals-node ./backend`

```bash
docker run \
  --name goals-backend \
  -v "C:\Users\Hsin Han\Desktop\docker-containers-demo\multi-container-application\multi-01-starting-setup\backend:/app" \
  -v logs:/app/logs \
  -v /app/node_modules \
  -e MONGODB_USERNAME=hh \
  --rm -p 80:80 \
  --network goals-net \
  goals-node
```

| 參數 | 說明 |
|------|------|
| `-v <host-path>:/app` | bind mount，本機程式碼同步至容器（開發用熱更新） |
| `-v logs:/app/logs` | named volume，持久化 log 檔 |
| `-v /app/node_modules` | anonymous volume，防止 bind mount 覆蓋容器內的 node_modules |
| `-e MONGODB_USERNAME=hh` | 傳入 MongoDB 帳號（密碼請另外設 MONGODB_PASSWORD） |
| `-p 80:80` | 對外開放 port 80 |
| `--network goals-net` | 加入與 MongoDB 相同的網路 |

---

## 3. Frontend (React)

> 執行前先 build image：`docker build -t goals-react ./frontend`

```bash
docker run \
  --name goals-frontend \
  -e WATCHPACK_POLLING=true \
  -v "C:\Users\Hsin Han\Desktop\docker-containers-demo\multi-container-application\multi-01-starting-setup\frontend\src:/app/src" \
  --rm -p 3000:3000 \
  -it \
  goals-react
```

| 參數 | 說明 |
|------|------|
| `-e WATCHPACK_POLLING=true` | 讓 React dev server 在 Docker bind mount 環境下正確偵測檔案變更 |
| `-v <host-path>/src:/app/src` | bind mount src 目錄，支援熱更新 |
| `-p 3000:3000` | 對外開放 React dev server port |
| `-it` | 保持互動式 TTY（React dev server 需要） |

---

## 停止所有容器

```bash
docker stop mongodb goals-backend goals-frontend
```
