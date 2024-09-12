'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "c554c80f5456719f0dae48ddbfdf8409",
"assets/AssetManifest.bin.json": "e6fc9c755e30426d7646188f78c8693a",
"assets/AssetManifest.json": "642d50f70ab0121e5dcf266d3bbd3f19",
"assets/assets/bracket_control.js": "192ccdc2d2134d718c6506c8476d1510",
"assets/assets/convert.js": "1fee13da3491ca3604098bdfeaafdc5b",
"assets/assets/cvuAceEditorDist/bundle.simple.js": "0b8a84b38d4fa36d05604fcd90bfc9a5",
"assets/assets/cvuAceEditorDist/bundle.simple.js.map": "6562fda17f9120f2c8b2cda1b4e22e77",
"assets/assets/cvuAceEditorDist/index.html": "0004dabae06ec0d13c305dc29aa3cf94",
"assets/assets/defaultCVU/named/allItems.cvu": "9f5e51292066951824410bb5528bbf48",
"assets/assets/defaultCVU/named/auth-view.cvu": "5e459a5406d2a849be932afc941470c0",
"assets/assets/defaultCVU/named/calendar.cvu": "e51e0d82a2914d67bda430b0cb50092e",
"assets/assets/defaultCVU/named/chartExamples.cvu": "21e308b5a32180c7bbc948698b3b6d45",
"assets/assets/defaultCVU/named/filter-starred.cvu": "e4019ccc744460f751bc1f362b713f11",
"assets/assets/defaultCVU/named/inbox.cvu": "38a30ddc056549833a070b78f13919c1",
"assets/assets/defaultCVU/named/itemByQuery.cvu": "f86c61f50c37b2d8959663c00999a6bb",
"assets/assets/defaultCVU/named/messageChannelView.cvu": "cfe2e77e5b205cf5a33b455e872a68c5",
"assets/assets/defaultCVU/named/onboarding.cvu": "fa7ab13ffe07b5cd172fb393aaef8877",
"assets/assets/defaultCVU/named/user.cvu": "df8aec258a79e75149aa47e7c59d6d22",
"assets/assets/defaultCVU/renderer/calendar.cvu": "5ed7e93b517eed75163dfc12d96bce40",
"assets/assets/defaultCVU/renderer/chart.cvu": "997a1ac055af557eb791b793741a544f",
"assets/assets/defaultCVU/renderer/generalEditor.cvu": "2bb95910f2f65d2e14d70c21a683d3e0",
"assets/assets/defaultCVU/renderer/grid.cvu": "0e7dad49439ce73fc7614f029ecddfd9",
"assets/assets/defaultCVU/renderer/list.cvu": "d259fbc7395c61dabe68d4e1fde6dd81",
"assets/assets/defaultCVU/renderer/map.cvu": "a46b3c6d6ae3662f317688969fd42832",
"assets/assets/defaultCVU/type/Account.cvu": "98ab13b37b1b297dcb4b4a9153c96377",
"assets/assets/defaultCVU/type/Address.cvu": "4f2d2ffb06902ad6dcf61a6e7548d58a",
"assets/assets/defaultCVU/type/Any.cvu": "9914db8c73e55802008fb26b3afbf964",
"assets/assets/defaultCVU/type/AuditItem.cvu": "a3bc9334cf5b2491bb53d4b2171bb041",
"assets/assets/defaultCVU/type/CryptoCurrency.cvu": "c9c3dac389128e99bc45e192d815fbaa",
"assets/assets/defaultCVU/type/CryptoKey.cvu": "f6fd4170bb6c3e9fa9887ea10d4f24dc",
"assets/assets/defaultCVU/type/CryptoTransaction.cvu": "310b90aeffc5ba78d966601b5b759498",
"assets/assets/defaultCVU/type/CurrencyOwner.cvu": "c3d530bdc2236eb83455fb124023828e",
"assets/assets/defaultCVU/type/CurrencySetting.cvu": "cdde4374dec56d67c61eca336d911a6c",
"assets/assets/defaultCVU/type/EmailMessage.cvu": "7a1e7c37155a4f21b1b855b91283329c",
"assets/assets/defaultCVU/type/Importer.cvu": "87559daa496955e786a31cc0acab817f",
"assets/assets/defaultCVU/type/Indexer.cvu": "ed434c5672aaa6d6992a2e08c6be1891",
"assets/assets/defaultCVU/type/IndexerRun.cvu": "f092d988bb7062c22b9a0f8d6489da1f",
"assets/assets/defaultCVU/type/Label.cvu": "3870938804764fc3a6e1b2b850e131ba",
"assets/assets/defaultCVU/type/Message.cvu": "1078bf8f8552e4765a81298aa7539f08",
"assets/assets/defaultCVU/type/MessageChannel.cvu": "e50032ea794539f6b1c17aa17efeb351",
"assets/assets/defaultCVU/type/Note.cvu": "6ae0ad06230b5b1ac0e9f313f6ea46f0",
"assets/assets/defaultCVU/type/Person.cvu": "ec9439c98eee6e7abaa50ac8baec1d58",
"assets/assets/defaultCVU/type/Photo.cvu": "0c2048510ba4182eeb9ab776c8a6333f",
"assets/assets/defaultCVU/type/Plugin.cvu": "df3a2746e39b0393fce23f84b4bcc397",
"assets/assets/defaultCVU/type/Post.cvu": "f357ad03ab197aaa74d13e4afc9236e0",
"assets/assets/defaultCVU/type/Receipt.cvu": "e2c045854269da85639ca170d7e8e23c",
"assets/assets/defaultCVU/type/startPlugin.cvu": "84461401492efc9cc69f17910503cfbf",
"assets/assets/defaultCVU/type/Wallet.cvu": "ec4f9b312490f43440948e33a0ef8a63",
"assets/assets/demoAssets/ave-calvar-ukuIJ6ReFms-unsplash.jpg": "7ebb60b2b8c9ac0abde16ee41dbc036f",
"assets/assets/demoAssets/circles.jpg": "078daaaf2a69dcb6e145c1e0597eb1e2",
"assets/assets/demoAssets/demoReceiptPDF.pdf": "f1499a610aabb3902473aee67a1dd687",
"assets/assets/demoAssets/eth.jpg": "86b356aa4636232f3e200c65d2a8b6b4",
"assets/assets/demoAssets/fake-person0.jpg": "e6cdb9d4f8ed158df333ada6d067b08d",
"assets/assets/demoAssets/fake-person1.jpg": "a9417442745e86fd290c48c4b1013a31",
"assets/assets/demoAssets/fake-person10.jpg": "dac4678f4813c2a4ce8c7ff2b437f0d5",
"assets/assets/demoAssets/fake-person11.jpg": "f20dc5d23bead68d93e639be140a84b2",
"assets/assets/demoAssets/fake-person12.jpg": "a3ffdf75b2fe4d766ae61ea5e7a7a7a9",
"assets/assets/demoAssets/fake-person13.jpg": "e93c273505584717f2ac0602983d2761",
"assets/assets/demoAssets/fake-person14.jpg": "fb28ae91c7fdc84868cb14b722dd4b81",
"assets/assets/demoAssets/fake-person15.jpg": "f2362f2241c9a866472cef1721141c5b",
"assets/assets/demoAssets/fake-person16.jpg": "9425e7cb517395fecffddd415199c001",
"assets/assets/demoAssets/fake-person17.jpg": "2bca52c018daf2f6d57170ca8b7df31d",
"assets/assets/demoAssets/fake-person18.jpg": "5b3c65ea92298f37aead0718e4be679b",
"assets/assets/demoAssets/fake-person19.jpg": "d2ab672a2ff87a2a1cdd436677d14446",
"assets/assets/demoAssets/fake-person2.jpg": "81c0ccaca6d0b391890035239395c4d5",
"assets/assets/demoAssets/fake-person20.jpg": "6af8ad7b9e1cc7606273d7d2e981b9d5",
"assets/assets/demoAssets/fake-person21.jpg": "686314679d8f1946b5db45ed3215c68e",
"assets/assets/demoAssets/fake-person22.jpg": "02c78c1b8f4337773a9b4a6ccca4ee99",
"assets/assets/demoAssets/fake-person23.jpg": "aa92ddb553bda1aa8743be02665f508a",
"assets/assets/demoAssets/fake-person24.jpg": "1fa3c58380cbcf090c60ffdc370dfe48",
"assets/assets/demoAssets/fake-person25.jpg": "f4e8a6198f77801da87e1197031b09fc",
"assets/assets/demoAssets/fake-person26.jpg": "1f7a7f60e0eff9127ea5689078530a18",
"assets/assets/demoAssets/fake-person27.jpg": "6c400b175a46e84ca3db929bef6443aa",
"assets/assets/demoAssets/fake-person28.jpg": "ab5e4eb048aff984d333e41fa60ca76e",
"assets/assets/demoAssets/fake-person29.jpg": "85b43b3b92df73947428eddbcbb9351f",
"assets/assets/demoAssets/fake-person3.jpg": "d16d4d4e06c1fae1f307b3139b045d88",
"assets/assets/demoAssets/fake-person30.jpg": "74cab6d4ee060359278757bf4a426913",
"assets/assets/demoAssets/fake-person33.jpg": "3fb9d3bb4665a0f3cd83eb36bcc6af81",
"assets/assets/demoAssets/fake-person34.jpg": "9a37765922a328bded47f1083f4ea419",
"assets/assets/demoAssets/fake-person36.jpg": "9e0c33a40af076841a6677386c5902cf",
"assets/assets/demoAssets/fake-person4.jpg": "447a6ea4a9a28ddb1dde396d1bec2cda",
"assets/assets/demoAssets/fake-person41.jpg": "7657763c55b042ac3a5cfc156a87b955",
"assets/assets/demoAssets/fake-person43.jpg": "b222dd5b0ce89c51aff9a4aa438f59f7",
"assets/assets/demoAssets/fake-person49.jpg": "92a3fb46f3a973d3eeba1f911f85fbdf",
"assets/assets/demoAssets/fake-person5.jpg": "14c277297bc8cd443423304529a97113",
"assets/assets/demoAssets/fake-person50.jpg": "156cd3360a81898223003377df668076",
"assets/assets/demoAssets/fake-person51.jpg": "d2ab28e5b184bcfc5d952c6fa0d5652f",
"assets/assets/demoAssets/fake-person52.jpg": "20625dec8ab16fbdf2a5bb8ccf7ae193",
"assets/assets/demoAssets/fake-person54.jpg": "dfc865e8907ccf535c8ad06feae1d4eb",
"assets/assets/demoAssets/fake-person56.jpg": "e544fda00a839c75bbb7176110c66156",
"assets/assets/demoAssets/fake-person57.jpg": "e5d5d56c70e261ec7467b7c89477a07b",
"assets/assets/demoAssets/fake-person58.jpg": "6221ec71423fb0b3d46b76a1b45ba7bd",
"assets/assets/demoAssets/fake-person6.jpg": "94c8234ff76103c2955539221be88284",
"assets/assets/demoAssets/fake-person7.jpg": "2a0f521e2abf4bf24b9e0e356bdf0ef9",
"assets/assets/demoAssets/fake-person8.jpg": "33b2b865c5c6f14ef893577c86c5b404",
"assets/assets/demoAssets/fake-person9.jpg": "13def376a08cf3b518a4731ba78ba76a",
"assets/assets/demoAssets/iphone-image1.jpg": "a3f4c54aaa6369dc57cb66c5441d6d52",
"assets/assets/demoAssets/iphone-image11.jpg": "758ffccf793053810437db1eafd89d52",
"assets/assets/demoAssets/iphone-image2.jpg": "f9fd501eac7b3216c2a597036e480e97",
"assets/assets/demoAssets/iphone-image3.jpg": "88de34d9190938ef34bd34fd3810c03c",
"assets/assets/demoAssets/iphone-image4.jpg": "e09c3c5fdc50b338ad4c59fadcc9d5ba",
"assets/assets/demoAssets/iphone-image5.jpg": "b1de8a524bc727a8d639f6cda3e72480",
"assets/assets/demoAssets/iphone-image6.jpg": "fd08e15cd3c84a25596bef69e44f784e",
"assets/assets/demoAssets/iphone-image8.jpg": "5184c82a0756241630bd256a15e005ef",
"assets/assets/demoAssets/iphone-imager39.jpg": "7a2f062aa2b9a299b8f1f1c559db05df",
"assets/assets/demoAssets/iphone-imager43.jpg": "20b8fb9d08230be914425fe8686d3c14",
"assets/assets/demoAssets/iphone-imager67.jpg": "9853f887f1845289043d0e69719f348a",
"assets/assets/demoAssets/iphone-imager69.jpg": "c39693912c2e93bcf55ac9ad7a0744d7",
"assets/assets/demoAssets/iphone-imager71.jpg": "0722e6905f6411a82720df6847a20ac1",
"assets/assets/demoAssets/iphone-imager9.jpg": "55930ca590a9ec316398501cf5ad1db5",
"assets/assets/demoAssets/karen-penroz-06ZTGDcAQFs-unsplash.jpg": "a4d508ac16d8b38b92074582518eb198",
"assets/assets/demoAssets/katarzyna-korobczuk-pwUjBdc5U9c-unsplash.jpg": "d37c9bf3e13c0c05bb02b35d5f739f88",
"assets/assets/demoAssets/modern_family1.jpg": "61dc5281529f5e78d7fbc4149ea52157",
"assets/assets/demoAssets/modern_family2.jpg": "bb4c2e557e902ad75bf70203eeaffca4",
"assets/assets/demoAssets/modern_family3.jpg": "a2b7e5f103a2c65f6b3798f43ef0a2a4",
"assets/assets/demoAssets/modern_family4.jpg": "54fec1051301bbbb8e7fef67b1e84351",
"assets/assets/demoAssets/receiptDemo1.jpg": "cc61137ee59d2b1f69cd88b8392072e6",
"assets/assets/demoAssets/receiptDemo2.jpg": "fecba6ddca6d9ea97fa8567e28d4f659",
"assets/assets/demoAssets/receiptDemo3.jpg": "a94130af80dd113ed54614a41b307191",
"assets/assets/demoAssets/receiptDemo4.jpg": "ba50b119320ac95c843b588221d988b1",
"assets/assets/demoAssets/romeTripDemo1.jpg": "6d157261c4423926909a437b2d972a2d",
"assets/assets/demoAssets/romeTripDemo2.jpg": "b3a68c7abe08e6ebe7673e3836e48799",
"assets/assets/demoAssets/romeTripDemo3.jpg": "c8c215a720d39aae78056fa87f4f38f3",
"assets/assets/demoAssets/romeTripDemo4.jpg": "982c2d97e10120383847e17df4b24a4b",
"assets/assets/demoAssets/romeTripDemo5.jpg": "bcd178c9f964edde83d27893eedb4005",
"assets/assets/demoAssets/romeTripDemo6.jpg": "c8ed0e5948a85d247160db6c0b3d50d5",
"assets/assets/demoAssets/romeTripDemo7.jpg": "02c60d03d0473ac6b6abf679f0ca90ac",
"assets/assets/demoAssets/romeTripDemo8.jpg": "ab6de298956d33cabfd21b3d5b30b8a0",
"assets/assets/demoAssets/romeTripDemo9.jpg": "d2308d6f17365d6e22a500e00376f310",
"assets/assets/demoAssets/szabo-viktor-tarTTEaiIx4-unsplash.jpg": "c4b02f244a5e095fcdf5f8d8abf0917c",
"assets/assets/demoAssets/unsplash-image13.jpg": "e27d65464002d918a543aca89fc22cfe",
"assets/assets/demoAssets/unsplash-image16.jpg": "3f6412b6d9e0877be567e80b45c6938d",
"assets/assets/demoAssets/unsplash-image17.jpg": "a6964bd403d0d3d5f2ccc2e5e7744534",
"assets/assets/demoAssets/unsplash-image18.jpg": "8e212f9e4f41decc8970afc6593c5346",
"assets/assets/demoAssets/unsplash-image19.jpg": "2701a70c91d77f63c8693878e85b9793",
"assets/assets/demoAssets/unsplash-image2.jpg": "ad0c0b39a25a7429f01c3d4f61d469b2",
"assets/assets/demoAssets/unsplash-image20.jpg": "1e61d957d117519b007724d2d9812967",
"assets/assets/demoAssets/unsplash-image21.jpg": "4164f0847e241982361a3edb2a36c553",
"assets/assets/demoAssets/unsplash-image22.jpg": "a37a9b064d906c5bffba8c531ff24564",
"assets/assets/demoAssets/unsplash-image23.jpg": "b5e65a9b60319d76115842118d534dcf",
"assets/assets/demoAssets/unsplash-image24.jpg": "c7e02988bdc6bde909a450ed2c5586fa",
"assets/assets/demoAssets/unsplash-image25.jpg": "6d489d96c5814d2cd1e2db839bd91939",
"assets/assets/demoAssets/unsplash-image27.jpg": "5a3a867a19960deeeeacce501c81d15c",
"assets/assets/demoAssets/unsplash-image28.jpg": "8a9ca2e76dddace7893d476766df87a5",
"assets/assets/demoAssets/unsplash-image29.jpg": "f8e7dde39c9f213fa5c32eb2869cc9cd",
"assets/assets/demoAssets/unsplash-image30.jpg": "a0edd65af581e129fd9a1a2e0fb03553",
"assets/assets/demoAssets/unsplash-image55.jpg": "778d41bc7bf710c4986f8e5baa9de7f1",
"assets/assets/demoAssets/unsplash-image57.jpg": "70fd3a46404a75f256b2899dd1732228",
"assets/assets/demoAssets/unsplash-image58.jpg": "81d453c2a9b5497f1dcf1e50203ccf31",
"assets/assets/demoAssets/unsplash-image59.jpg": "19adb2067020cd158c6adfc365298e50",
"assets/assets/demoAssets/unsplash-image6.jpg": "5edf42eef3ef3171e02baf5eee62a6c6",
"assets/assets/demoAssets/unsplash-image60.jpg": "e82c3ec112159b2d6772b14af8b17ed2",
"assets/assets/demo_database.json": "788b22351c9a7172e4be1b4ed6d47ff1",
"assets/assets/dev_database.json": "34faeb0c7dd1ffc1363079fa86f8488f",
"assets/assets/fonts/Karla-Bold.ttf": "008289c29878b73e3dbfbd85d41a75f0",
"assets/assets/fonts/Karla-ExtraBold.ttf": "deb29edabac74e45b03c66b59c1e2282",
"assets/assets/fonts/Karla-ExtraLight.ttf": "8c255a16306879f2fb968239cdd62696",
"assets/assets/fonts/Karla-Italic.ttf": "a399819373a4906b3a9b65755bedb74c",
"assets/assets/fonts/Karla-Light.ttf": "345e34af5689a037bcf1c203e7f48ef2",
"assets/assets/fonts/Karla-Medium.ttf": "fc3c77ce1e2e821dc52aaeaa8e03f27e",
"assets/assets/fonts/Karla-Regular.ttf": "8f456584c855750cf2eb1c28f39753e5",
"assets/assets/fonts/Karla-SemiBold.ttf": "377c995cdc95f97aa358c7e5a2599d34",
"assets/assets/graphql_query.js": "ce18450148fce7635f5ff67101fb6fcd",
"assets/assets/HTMLResources/purify.min.js": "2d5c78cf3d2a8078afbfcccb018c187f",
"assets/assets/icons/ico_arrow_down.svg": "30df61de7806a69432f9a9d885472230",
"assets/assets/icons/ico_arrow_right.svg": "cd2fbc9e07b5056f78bd3f0c3fe7c5e2",
"assets/assets/icons/ico_brcmb_line.svg": "78265d3c2c3b81163991345eb6928daa",
"assets/assets/icons/ico_check.svg": "6854f0fd7a1715ff098c748e9927d838",
"assets/assets/icons/ico_close.svg": "24d7f0ebef7fde92478dbef3afb46bc7",
"assets/assets/icons/ico_copy_to_clipboard.svg": "6ceaed209c017876f0df9184d6b5832a",
"assets/assets/icons/ico_hamburger.svg": "9599415a67eca8446dab2f717dbed499",
"assets/assets/icons/ico_ignore.svg": "bbe7275ebb535d54e4b2a8393d75b0d7",
"assets/assets/icons/ico_key.svg": "a19dfc870edab36cbbe572c5432905b8",
"assets/assets/icons/ico_loader.svg": "11ac0730bcbda3be5cc5ab1c338148ce",
"assets/assets/icons/ico_log_out.svg": "a2aaefaf956773ea70a356a964c1a3be",
"assets/assets/icons/ico_rotate_ccw.svg": "86888b22c1f52d0faf5a4d4a3c233c63",
"assets/assets/images/arrow-right-circle.svg": "8b51f5e233068d351618c5b368ba5d8b",
"assets/assets/images/background.jpg": "e7c700615ffdc5a71d2b47d22429580a",
"assets/assets/images/coffee.svg": "e5c93e14d05a9405c75c39e1d416eaab",
"assets/assets/images/file-text.svg": "fc96d495316d4ae7625f3169f732a7bf",
"assets/assets/images/google_colab.svg": "0815fad6d2217ea486ef9d45aa38e777",
"assets/assets/images/grid.svg": "e4091628af08023f73d87219cf532149",
"assets/assets/images/home.svg": "dcc208ad86496d07ed3beba8fbf6d569",
"assets/assets/images/ico_arrow.svg": "4acd539eee84e6448e3162cc96c62877",
"assets/assets/images/ico_arrow_left.svg": "25f9e69ba4b25763c9538bee3d0fa132",
"assets/assets/images/ico_arrow_long.svg": "cb0df1cd2dceeae7b611ba7ddfc86019",
"assets/assets/images/ico_arrow_top_right.svg": "f9782254f0aaf0dc1dbb5bb9a2b8ec4d",
"assets/assets/images/ico_check.svg": "a37db4574104e81824d9a1b31101401e",
"assets/assets/images/ico_dataset_new.svg": "eb7ede233d5f477bda745e67d1906279",
"assets/assets/images/ico_delete.svg": "c478b95403695b157dce5d86b16704d5",
"assets/assets/images/ico_log_out_rotated.svg": "8cdc504fa3d4b5925a22f7594073f14d",
"assets/assets/images/ico_lt.svg": "d3196aec9e820a94fc0e50e0fcb232ff",
"assets/assets/images/ico_plus.svg": "604a3b2d1e514700e9499d7c5af53557",
"assets/assets/images/ico_search.svg": "977eaeb6f50402552fc4452a7c606365",
"assets/assets/images/ico_terminal.svg": "85b898ef6d49175896eb1f4b43ee1a75",
"assets/assets/images/image.png": "181de78b13018d8f891680499ae48930",
"assets/assets/images/image.svg": "5e2bedef88e70e749eaddf2f062c5c46",
"assets/assets/images/inbox.svg": "061e5859fdbdf70cc5e54ca6a34b20ac",
"assets/assets/images/log-out.svg": "cbed27a151749b15dee7ca9765df2e71",
"assets/assets/images/logo.svg": "ab9da03f3d6302fbbec404aa040f4523",
"assets/assets/images/person.png": "84fd40d4369495ec7ae5290dbbdac9dc",
"assets/assets/images/plus.svg": "e7274eec903af7f7692038eab6ebc4d5",
"assets/assets/images/rotate_ccw.svg": "dbe6742afddf9be9caad39dc099191a4",
"assets/assets/images/settings.svg": "791ec87269e8181930e5717d133fd592",
"assets/assets/images/sign_first.svg": "9a26e3df3191da37104eda791237354b",
"assets/assets/images/sign_fourth.svg": "86341d0cd5573c6c0fdc08a42b91a3ef",
"assets/assets/images/sign_second.svg": "d555ffe1b71e592968bc7a984481eb2b",
"assets/assets/images/sign_third.svg": "e5d5023c824c966d03df693f936f8a11",
"assets/assets/images/upload-cloud.svg": "ea3988cae175c884aa47532df03c1596",
"assets/assets/images/users.svg": "e852b6b189d4dd8318e85e8e35c27b77",
"assets/assets/images/x.svg": "6d0dab9d74075dbf045f56f3c18b722e",
"assets/assets/images/zap.svg": "534c25bfb387e5275ce7470709ada217",
"assets/assets/noteEditor/noteEditorDist/css/app.21afb81e.css": "44591623bc1ed62d55d78982c7178af9",
"assets/assets/noteEditor/noteEditorDist/index.html": "e6b19167c9c229d45b3b9462d7fe1f47",
"assets/assets/noteEditor/noteEditorDist/js/app.aa7a2c74.js": "e20530511160f195020036c5fb8dc8b2",
"assets/assets/noteEditor/noteEditorDist/js/app.aa7a2c74.js.map": "417bd2264eafe1a7350e7ebef670623b",
"assets/assets/noteEditor/noteEditorDist/js/chunk-vendors.cfa982ac.js": "8cf6fc3a4be998afcacbb05de46e8bdb",
"assets/assets/noteEditor/noteEditorDist/js/chunk-vendors.cfa982ac.js.map": "8704c4176449f196fadb7b4cdce5ac94",
"assets/assets/outputSchema.json": "c579208606453165c9a88dcf7b78bde2",
"assets/assets/prod_database.json": "69c63fe18fd45cbaf69e17f6b53063b5",
"assets/assets/qa_database.json": "e4a7fcb84eebcb4205a7f51bf25acace",
"assets/assets/schema-new.json": "bc5b99c2c64c2df634f8920925df1b90",
"assets/assets/schema.json": "ba9f3e8b4b5897cf1913c164690c233e",
"assets/assets/uat_database.json": "47948e9bbbda59dba94e5f4b36555c1c",
"assets/FontManifest.json": "23d8f06791321c9d61f815166e27aec0",
"assets/fonts/MaterialIcons-Regular.otf": "951cb82a71d657306fb60f39ef06b92e",
"assets/NOTICES": "48c15247a274119a7c27902d58c3747e",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/flutter_dropzone_web/assets/flutter_dropzone.js": "5530dc96a013849f2739b2393d1b8102",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "01a564f71022e77c4d7b5ff44632b349",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "291b459c47d13856c4e2d8075347f3a0",
"/": "291b459c47d13856c4e2d8075347f3a0",
"main.dart.js": "5d836e5980784931b79942173cf94551",
"manifest.json": "a3b3dd8d9a34835708111663604a6613",
"version.json": "df60a9e6491735f93583ca635a6fc95b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
