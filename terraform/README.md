## 構成

```bash
terraform-keycloak/
├── main.tf          # ルートモジュール（各モジュールを呼び出す）
├── variables.tf     # ルート変数定義
├── outputs.tf       # ルート出力
└── modules/
    ├── network/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── compute/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── alb/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## 構築フロー

以下は、各ステージごとにターゲット指定で apply する場合の例です。  
**※ 初回はルートディレクトリで `terraform init` を実行してください。**

### 1. ルートディレクトリで初期化

```bash
terraform init
```

### 2. ステージ 1 – ネットワーク構築

VPC、サブネット、IGW、ルートテーブルを作成します。

```bash
terraform plan -target=module.network
terraform apply -target=module.network
```

### 3. ステージ 2 – EC2 インスタンス構築

Compute モジュールで Keycloak 用の EC2 インスタンスを作成します。

```bash
terraform plan -target=module.compute
terraform apply -target=module.compute
```

### 4. ステージ 3 – ALB ＋ ACM の構築

ALB と ACM 証明書の作成を行います。  
※ 初回 apply 後、出力される `cert_validation_options` を確認し、お名前ドットコムの DNS 管理画面で手動で検証用のレコードを追加してください。

```bash
terraform plan -target=module.alb
terraform apply -target=module.alb
```

### 5. DNS 検証レコードの反映後

お名前ドットコム側で検証用レコードを追加したら、  
変数 `manual_validation_fqdns` に該当の FQDN（例：`_abcde.example.com.`）を設定し、再度 ALB モジュールのみ apply します。

```bash
terraform plan -target=module.alb
terraform apply -target=module.alb
```

### 6. 最終確認

出力された `alb_dns_name` をもとに、お名前ドットコム側でカスタムドメインの CNAME（または ALIAS）設定を行ってください。  
また、出力の `keycloak_url_https` で HTTPS アクセスが可能なことを確認してください。
