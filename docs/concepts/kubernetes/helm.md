# Helm の基本的な使い方

[Kubernetes][1]の問題の１つに、[マニフェスト][2]ファイルがたくさんできる[YAMLの壁][3]と呼ばれるものがあります。

* image
* mountするファイル
* label
* リソース割当

といった一部の要素だけ変えたい時、ほとんど構成は同じで似たような[マニフェスト][2]ファイルが大量に出てしまいます。  
そしてそういったファイルは往々にして管理されず負債となっていきます。

それを解決するのがHelmという[Kubernetes][1]のパッケージマネージャです。  
共通部分をテンプレート化し、可変部分を変数で扱えるようになります。

今回はそのHelmの基本的な使い方を説明します。

Helmをシステム[アーキテクチャ][4]は以下です。

![f:id:quoll00:20190806154207p:plain][5]

_ref: [Simplifying App Deployment in Kubernetes with Helm Charts][6]_

図からわかるようにTillerと呼ばれるサーバが[Kubernetes][1] Cluster内で起動し、[api][7]-serverをコールしてデプロイを行います。

覚えておいた方がよい単語は以下です。

| 用語      | 説明                                   |  
| ------- | ------------------------------------ |  
| Chart   | Helmで利用するパッケージのテンプレート                |  
| Tiller  | [Kubernetes][1] Cluster上で稼働するHelmサーバ |  
| Release | Chartをデプロイした単位                       |  

### RBAC

前回の

[christina04.hatenablog.com][8]

でRBACについて書きましたが、helmのtillerが[api][7]-serverを叩くので権限が必要になります。

#### Namespaceの用意

今回は専用のNamespaceを用意しておきます。
    
    
    $ kubectl create namespace helm
    

#### ServiceAccount作成
    
    
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: tiller
      namespace: helm
    

#### ClusterRoleBinding
    
    
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: tiller
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: tiller
      namespace: helm
    

### Tillerの起動

先ほどのServiceAccountを使い、`helm init`でTiller Serverを起動します。
    
    
    $ helm init --tiller-namespace helm --service-account tiller
    

確認します。
    
    
    $ helm version --tiller-namespace helm
    Client: &version.Version{SemVer:"v2.14.3", GitCommit:"0e7f3b6637f7af8fcfddb3d2941fcc7cbebb0085", GitTreeState:"clean"}
    Server: &version.Version{SemVer:"v2.14.3", GitCommit:"0e7f3b6637f7af8fcfddb3d2941fcc7cbebb0085", GitTreeState:"clean"}
    

### helmでprometheusをインストール

Release名を`test-prometheus`としてデプロイします。
    
    
    $ helm install --tiller-namespace helm 
      --name test-prometheus stable/prometheus
    

問題なく作成できます。
    
    
    $ kubectl get po
    NAME                                                 READY   STATUS    RESTARTS   AGE
    test-prometheus-alertmanager-6fb8c4d7f-6l77z         2/2     Running   0          84s
    test-prometheus-kube-state-metrics-948cdb5f6-xvlll   1/1     Running   0          84s
    test-prometheus-node-exporter-5xwx6                  1/1     Running   0          84s
    test-prometheus-pushgateway-6c4f8f8d6-rwjbf          1/1     Running   0          84s
    test-prometheus-server-7c9c9f7b9f-22v8g              2/2     Running   0          84s
    

### 各コマンド

簡単のためtiller-namespaceを[環境変数][9]で設定しておきます。
    
    
    $ export TILLER_NAMESPACE=helm
    

#### 一覧
    
    
    $ helm list
    NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
    test-prometheus 1               Tue Aug  6 20:31:14 2019        DEPLOYED        prometheus-8.11.4       2.9.2           default
    

この`REVISION`はupgradeやrollbackする際に繰り上がっていきます。

#### ステータス確認
    
    
    $ helm status test-prometheus
    LAST DEPLOYED: Tue Aug  6 23:26:25 2019
    NAMESPACE: default
    STATUS: DEPLOYED
    
    RESOURCES:
    ==> v1/ConfigMap
    NAME                          DATA  AGE
    test-prometheus-alertmanager  1     17s
    test-prometheus-server        3     17s
    ...
    

#### 削除

deleteで削除しますが、
    
    
    $ helm delete test-prometheus
    release "test-prometheus" deleted
    

実はReleaseのステータスが`DELETED`になるだけで残っています。
    
    
    $ helm status test-prometheus
    LAST DEPLOYED: Tue Aug  6 20:31:14 2019
    NAMESPACE: default
    STATUS: DELETED
    

podなどのリソースは削除されてます。

#### [ロールバック][10]

`REVISION`を指定して[ロールバック][10]します。
    
    
    $ helm rollback test-prometheus 1
    Rollback was a success.
    

[ロールバック][10]したので`REVISION`が上がってます。
    
    
    $ helm list
    NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
    test-prometheus 2               Tue Aug  6 23:26:25 2019        DEPLOYED        prometheus-8.11.4       2.9.2           default
    

#### upgrade

`fetch`でChartをダウンロードして
    
    
    $ helm fetch stable/prometheus
    

展開してファイルをいじってから`upgrade`します。
    
    
    $ helm upgrade test-prometheus prometheus/
    Release "test-prometheus" has been upgraded.
    LAST DEPLOYED: Tue Aug  6 23:42:23 2019
    NAMESPACE: default
    STATUS: DEPLOYED

#### 完全削除

`\--purge`をつけると完全に消えます。
    
    
    $ helm delete --purge test-prometheus
    

### 通常RBACのエラーはどんなの？

RBACが有効な環境の場合、正しいServiceAccountを用意しないと以下のエラーが出ます。
    
    
    $ helm install --name test-prometheus stable/prometheus
    Error: release test-prometheus failed: namespaces "default" is forbidden: User "system:serviceaccount:kube-system:default" cannot get resource "namespaces" in API group "" in the namespace "default"
    

### \--tiller-namespaceが面倒くさい

helmのTiller Serverのデフォルトのnamespaceは

> Helm will look for Tiller in the `kube-system` namespace unless `\--tiller-namespace` or `TILLER_NAMESPACE` is set.

_ref: [Helm |][11]_

とあるように、`kube-system`になっています。

なので`kube-system:default`のServiceAccountにClusterRoleBindingを設定すれば不要になります。
    
    
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: tiller
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: default
      namespace: kube-system
    

もちろん先程のように[環境変数][9]`TILLER_NAMESPACE`で設定するのも１つです。

### minikubeの場合RBACのServiceAccount不要

minikubeの場合、helmが扱いやすいよう`minikube-rbac`というClusterRoleBindingが存在します。
    
    
    $ kubectl get clusterrolebinding minikube-rbac -o yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      creationTimestamp: "2019-08-06T10:57:51Z"
      name: minikube-rbac
      resourceVersion: "237"
      selfLink: /apis/rbac.authorization.k8s.io/v1/clusterrolebindings/minikube-rbac
      uid: a7210a35-4d6a-4c18-bd6d-15e72f5fbb8a
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: default
      namespace: kube-system
    

これは`kube-sysmte:default`に`cluster-admin`権限を付与してるので特に設定しなくてもhelmが自由に使えます。

### Docker for [Mac][12]の場合もRBAC設定不要

[Kubernetes のRBACを理解する - Carpe Diem][8]

で書いたように`default:default`含む全てのServiceAccountにcluster-admin権限があるので不要です。

今回使用したコードはこちら

[github.com][13]

[1]: http://d.hatena.ne.jp/keyword/Kubernetes
[2]: http://d.hatena.ne.jp/keyword/%A5%DE%A5%CB%A5%D5%A5%A7%A5%B9%A5%C8
[3]: https://deeeet.com/writing/2018/01/10/kubernetes-yaml/
[4]: http://d.hatena.ne.jp/keyword/%A5%A2%A1%BC%A5%AD%A5%C6%A5%AF%A5%C1%A5%E3
[5]: https://cdn-ak.f.st-hatena.com/images/fotolife/q/quoll00/20190806/20190806154207.png "f:id:quoll00:20190806154207p:plain"
[6]: https://supergiant.io/blog/simplifying-app-deployment-in-kubernetes-with-helm-charts/
[7]: http://d.hatena.ne.jp/keyword/api
[8]: https://christina04.hatenablog.com/entry/kubernetes-rbac
[9]: http://d.hatena.ne.jp/keyword/%B4%C4%B6%AD%CA%D1%BF%F4
[10]: http://d.hatena.ne.jp/keyword/%A5%ED%A1%BC%A5%EB%A5%D0%A5%C3%A5%AF
[11]: https://helm.sh/docs/install/#easy-in-cluster-installation
[12]: http://d.hatena.ne.jp/keyword/Mac
[13]: https://github.com/jun06t/kubernetes-sample/tree/master/helm-rbac

  
