[Source](https://cloud.google.com/blog/ja/products/containers-kubernetes/when-to-use-google-kubernetes-engine-vs-cloud-run-for-containers "Permalink to GKE と Cloud Run、どう使い分けるべきか | Google Cloud Blog")

# GKE と Cloud Run、どう使い分けるべきか | Google Cloud Blog

※この投稿は米国時間 2019 年 11 月 23 日に、Google Cloud blog に[投稿][1]されたものの抄訳です。

高度なスケーラビリティと構成の柔軟性を提供するコンテナ オーケストレーション プラットフォームを求めているお客様にとって、マネージド Kubernetes サービスである [Google Kubernetes Engine][2]（GKE）は優れた選択肢になります。GKE は、ステートフル アプリケーションのサポートに加えて、ネットワーキング、ストレージ、オブザーバビリティ（可観測性）のセットアップなど、コンテナ オーケストレーションのあらゆる側面を完全に制御できます。

しかしながら、お使いのアプリケーションがそうしたレベルのクラスタ構成やモニタリングを必要としない場合は、フルマネージドの [Cloud Run][3] が最適なソリューションになるかもしれません。フルマネージド Cloud Run は、Kubernetes の名前空間、ポッドでのコンテナ共存（サイドカー）、ノードの割り当てや管理といった機能を必要としないコンテナ化されたステートレス マイクロサービスにうってつけの[サーバーレス プラットフォーム][4]です。

### なぜ Cloud Run なのか

マネージド サーバーレス コンピューティング プラットフォームである Cloud Run は、さまざまな機能やメリットを提供します。

* **マイクロサービスの容易なデプロイ : **コンテナ化されたマイクロサービスをシングル コマンドでデプロイでき、サービス固有の構成は不要です。
* **シンプルで統一的なデベロッパー エクスペリエンス : **各マイクロサービスは、Cloud Run のデプロイ単位である Docker イメージとして実装されます。
* **スケーラブルなサーバーレス実行 : **マネージド Cloud Run にデプロイされるマイクロサービスは、リクエスト数に応じて自動的にスケーリングします。本格的な Kubernetes クラスタの構成や管理は不要です。マネージド Cloud Run は、リクエストがない場合はゼロにスケーリングし、リソースを使用しません。
* **任意の言語で書かれたコードのサポート : **Cloud Run はコンテナをベースとしているので、任意の言語でコードを作成でき、任意のバイナリやフレームワークを使用できます。

Cloud Run は [2 つの構成][3]で利用できます。フルマネージドの Google Cloud サービスとして、そして Cloud Run for Anthos としてです（後者では Cloud Run を Anthos GKE クラスタにデプロイします）。すでに Anthos をお使いの場合は、Cloud Run for Anthos で[コンテナをお客様のクラスタにデプロイ][5]し、カスタム マシンタイプや高度なネットワーキング サポート、GPU を利用して、Cloud Run サービスを強化できます。マネージド Cloud Run サービスと GKE クラスタは、いずれもコンソールとコマンドラインの両方から完全に作成、管理することが可能です。

しかも、便利なことに、マネージド Cloud Run と Cloud Run for Anthos は、サービスを実装し直すことなく、後で方針を変えて相互に簡単に切り替えることができます。

### Cloud Run のユース ケース

以上の点を具体的に理解していただくために、ユース ケースの例として、アドレスの追加、更新、削除、一覧表示を行うサービスを見てみましょう。

このアドレス管理サービスを実装するには、それぞれの操作ごとに、コンテナ化されたマイクロサービスを 1 つ作成します。そして、イメージを作成してコンテナ レジストリに登録したら、シングル コマンドでマネージド Cloud Run にデプロイできます。4 つのコマンドを実行すると（各マイクロサービスを 1 つずつデプロイ）、完全にサーバーレスなプラットフォームでサービスが稼働します。下の図は、基盤データベースとして Cloud Spanner を使ったデプロイを示しています。

[1]: https://cloud.google.com/blog/products/containers-kubernetes/when-to-use-google-kubernetes-engine-vs-cloud-run-for-containers
[2]: https://cloud.google.com/kubernetes-engine/?hl=ja
[3]: https://cloud.google.com/run/?hl=ja
[4]: https://en.wikipedia.org/wiki/Serverless_computing
[5]: https://cloud.google.com/run/docs/quickstarts/prebuilt-deploy-gke?hl=ja

  
