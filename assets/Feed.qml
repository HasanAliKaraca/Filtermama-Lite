import bb.cascades 1.0

BasePage {
    id: tabFeed
    property variant feedPhotos

    onCreationCompleted: {
        // you can change the head image to whatever you like for each page
        headerimage.imageSource = "asset:///images/header-filtermama.png";
    }

    ListView {
        id: photosList

        property alias feedDataModel: feedDataModel

        verticalAlignment: VerticalAlignment.Top
        horizontalAlignment: HorizontalAlignment.Left
        scrollIndicatorMode: ScrollIndicatorMode.Default
        snapMode: SnapMode.None
        flickMode: FlickMode.Momentum
        bufferedScrollingEnabled: true

        onCreationCompleted: {
            app.photosChanged.connect(addThumbToDataModel)
            loadPhotos()
        }

        layout: GridListLayout {
            headerMode: ListHeaderMode.None
            columnCount: 3
        }

        function itemType(data, indexPath) {
            return "item";
        }

        dataModel: ArrayDataModel {
            id: feedDataModel
        }

        function handleThumbClick(thumbData) {
            var path = thumbData.replace(".tmp/", "");
            app.invokePhotoViewer(path);
        }

        function addThumbToDataModel(filepath) {
            var newThumb = [ "file://" + filepath ];
            feedDataModel.insert(0, newThumb[0]);
        }

        function loadPhotos() {
            var photos = app.getPhotos();
            feedPhotos = photos.split(",");
            var length = feedPhotos.length;

            for (var i = 0; i < length; i ++) {
                if (feedPhotos[i] !== "") {
                    feedDataModel.insert(0, feedPhotos[i])
                }
            }
        }

        listItemComponents: [
            ListItemComponent {
                type: "item"
                Container {
                    id: feedItem

                    Container {
                        verticalAlignment: VerticalAlignment.Bottom
                        horizontalAlignment: HorizontalAlignment.Center

                        ImageButton {
                            preferredHeight: 334
                            preferredWidth: 334
                            defaultImageSource: ListItemData
                            pressedImageSource: ListItemData

                            onClicked: {
                                feedItem.ListItem.view.handleThumbClick(ListItemData)
                            }
                        }
                    } // container
                } // container
            } // listitemcomponent
        ]
    }

    attachedObjects: [
        ImagePaintDefinition {
            id: back
            repeatPattern: RepeatPattern.XY
            imageSource: "asset:///images/background-body-fullsize.png"
        }
    ]

    actions: [
        ActionItem {
            title: qsTr("Capture") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/camera.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                filepicker.open();
            }
        }
    ]
}
