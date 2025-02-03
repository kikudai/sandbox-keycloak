## keycloak の Docker 構築

### docker 環境構築
```
docker-compose up -d
```

### docker 設定やり直したいとき
```
docker-compose down
docker-compose up -d
```

### Docker を全て消し去りたいとき
```
docker-compose down --rmi all --volumes --remove-orphans
```


## keycloak の SAML 設定
M365にKeycloakでSAML認証するための設定

### remlm 作成
* Realm選択で [Create realm] ボタンを押す
* Realm name に m365-sso を入力
* 他の項目はそのまま
![Create realm](create_realm.png)

### ユーザー追加
* 左メニューで、 [Users] をクリック
* [Add user] をクリック
* Username に メアド を入力
* Email に メアド を入力
* First name を入力
* Last name を入力
* [Create] ボタンを押す

### 作成されたユーザーのパスワード設定
* 作成されたユーザーをクリック
* [Credentials] タブをクリック
* 

## Client Scopes のSAML設定

### Client Scopes 作成
* 左メニューの [Client scopes] をクリック
* [Create client scope] ボタンをクリック
* Name に m365-saml と入力
* Type で Default を選択
* Protocol で SAML を選択
* Include in token scope で On に設定
* 他の項目はそのまま
![Create client scope](create_client_scope.png)

### Mappers 設定
* 作成した m365-saml を選択し [Mappers] タブをクリック
* [Add predefined mapper] ボタンを押す
* [X500 email]　[X500 givenName] [X500 surname] をチェックして [Add] ボタンをクリック
![Add mapper](add_mapper.png)

### 各 X500 設定
#### X500 surname
* http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname
![X500 surname](x500_surname.png)

#### X500 givenName
* http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname
![X500 givenName](x500_givenName.png)

#### X500 email
* http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress
![X500 email](x500_email.png)

## Client の Client Scopes 設定
* 左メニュー [Clients] を開く
* [Create client] をクリック

|項目|設定値|
|---|---|
|Client ID|m365-saml-client（任意の名称）|
|Client Type|SAML|
|Name|Microsoft 365 SAML Client（任意の説明）|

| 設定項目 | 入力する値 | 説明 |
| --- | --- | --- |
| Root URL | (空欄のままでOK) | 通常は不要（特定のSP URLを指定する場合のみ） |
| Home URL |(空欄のままでOK)|必要に応じてSPのURL（M365では不要）|
| Valid Redirect URIs | https://login.microsoftonline.com/{tenant_id}/saml2 | M365 の SAML ACS (Assertion| |Consumer Service) URL |
| Valid Post Logout Redirect URIs | https://login.microsoftonline.com/ | M365 のログアウト後のリダイレクト先 |
| IDP-Initiated SSO URL Name | m365-sso（任意） | Keycloak から IDP-initiated SSO を行う場合の識別名 |
| IDP Initiated SSO Relay State | (空欄のままでOK) | 特定のアプリケーションへのリダイレクトが必要な場合のみ設定 |
| Master SAML Processing URL | https://login.microsoftonline.com/{tenant_id}/saml2 | M365 の SAML 処理 URL |

|設定項目|変更前|変更後|
|---|---|---|
|Name ID Format|username|urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress|
|Sign Assertions|OFF|ON|
|SAML Signature Key Name|NONE|KEY_ID|

### Client Scopes の role list, saml_organization を削除
