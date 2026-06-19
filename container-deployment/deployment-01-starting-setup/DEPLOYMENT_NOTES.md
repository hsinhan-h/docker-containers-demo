# 部署到 AWS EC2

## 1. 建立 EC2 Infrastructure

1. 建立 EC2 Instance、VPC、Security Group
2. 設置 Security Group 並 expose 必要的 port
3. 透過 SSH 連線到 instance，安裝 Docker 並執行 container

---

## 2. 本地建置與測試

```powershell
docker build -t node-dep-example .
docker run -d --rm --name node-dep -p 80:80 node-dep-example
```

---

## 3. 建立 SSH 連線

建立 EC2 instance 時會下載 `.pem` 私鑰檔案，將 key pair (`.pem`) 放到專案目錄下以建立 SSH 連線。

> 可透過 EC2 Console 的 **Connect** 頁面查看連線指令與說明。

---

## 4. 在 EC2 安裝並啟用 Docker

透過 SSH 連線進入 EC2 後，執行以下指令：

```bash
sudo yum update -y
sudo yum -y install docker

sudo service docker start

sudo usermod -a -G docker ec2-user

# 登出再重新登入讓群組變更生效 (exit 離開 SSH)

sudo systemctl enable docker

# 確認 Docker 是否正常運作
docker version
```

---

## 5. 推送 Image 至 Docker Hub

### 部署方式選擇

| 方式 | 說明 |
|------|------|
| **Option 1** | Deploy Source（直接在遠端建置） |
| **Option 2 (推薦)** | Deploy Built Image（推送 image 至 registry）|

### 步驟：推送 Image

前往 Docker Hub 建立 repository，接著在本地執行：

```powershell
docker build -t node-dep-example-1 .

docker tag node-dep-example-1 hsinhanh/node-example-1  # Docker Hub repository 名稱

docker login
docker push hsinhanh/node-example-1
```

### 步驟：在 EC2 拉取並執行 Image

切換回 SSH terminal：

```bash
docker run -d --rm -p 80:80 hsinhanh/node-example-1
```

---

## 6. 開放 HTTP 流量（Security Group）

執行上一步後，透過 EC2 的公開 IPv4 網址訪問，**此時仍無法看到網站**。

**原因**：Security Group 的 Inbound Rules 預設只開放 port `22`（SSH）。

**解決方式**：
1. 進入 EC2 Console > Security Groups
2. 編輯 **Inbound Rules**
3. 新增規則：`Type: HTTP`，`Port: 80`，`Source: 0.0.0.0/0`

儲存後重新訪問 IPv4 網址，即可看到部署完成的網頁。
