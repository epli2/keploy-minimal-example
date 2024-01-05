FROM node:20.10-alpine3.19 as builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

### アプリケーションが行うTLS通信をKeployで読み取れるように証明書をインストールしておく必要がある
### 証明書とインストール用スクリプトのダウンロード
RUN apk add curl
RUN curl -o ca.crt https://raw.githubusercontent.com/keploy/keploy/main/pkg/proxy/asset/ca.crt
RUN curl -o setup_ca.sh https://raw.githubusercontent.com/keploy/keploy/main/pkg/proxy/asset/setup_ca.sh
RUN chmod +x setup_ca.sh
###

FROM node:20.10-alpine3.19

WORKDIR /app

### 証明書とインストール用スクリプトのコピー
COPY --from=builder /app/ca.crt .
COPY --from=builder /app/setup_ca.sh .
RUN apk add bash
###

COPY --from=builder /app/node_modules ./node_modules
COPY index.mjs .

EXPOSE 3000

## 証明書インストール用スクリプトとアプリケーションを実行
CMD ["/bin/bash", "-c", "source ./setup_ca.sh && node /app/index.mjs"]
