import bb.cascades 1.0

TabbedPane {
    id: tabs
    showTabsOnActionBar: true
    peekEnabled: false

    property variant filePicked: false
    property variant filePath: false
    property variant fileSaved: false
    property variant thumbnailsLoaded: false
    property variant lastTab: null
    property variant workingDir: dirPaths.data

    attachedObjects: [
        ComponentDefinition {
            id: aboutSheetDefinition
            AboutSheet {
            }
        },

        BasePage {
            id: basePage
        }
    ]

    Menu.definition: MenuDefinition {
        // Add any remaining actions
        actions: [
            ActionItem {
                title: qsTr("About") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/about.png"
                onTriggered: {
                    var about = aboutSheetDefinition.createObject(app)
                    about.open();
                }
            },

            ActionItem {
                title: qsTr("Help") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/help.png"
                onTriggered: {
                    app.invoke("sys.browser", "bb.action.OPEN", "*", "http://palebanana.com");
                }
            },

            ActionItem {
                title: qsTr("Follow Me!") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/twitter.png"
                onTriggered: {
                    app.invoke("com.twitter.urihandler", "bb.action.VIEW", "*", "twitter:connect:@chadtatro");
                }
            },

            ActionItem {
                title: qsTr("Invite Friends") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/bbm.png"
                enabled: bbmHandler.allowed
                onTriggered: {
                    bbmHandler.sendInvite();
                }
            }
        ]
    }

    /* ==================================================
     *      feed
     * ==================================================
     */

    Tab {
        id: tabFeed
        title: qsTr("Feed") + Retranslate.onLanguageChanged
        imageSource: "asset:///images/feed.png"
        Feed {
        }
    }

    /* ==================================================
     *      processing
     * ==================================================
     */

    Tab {
        id: tabProcess
        title: qsTr("Process") + Retranslate.onLanguageChanged
        imageSource: "asset:///images/process.png"

        Filtering {
            id: filterPage
        }

        // update the webview
        function updateImage(imgData) {
            filterPage.updateWebview(imgData);
        }
    }

    /* ==================================================
     *     if no photo picked, goto last tab
     * ==================================================
     */

    onActiveTabChanged: {
        if (activeTab === tabProcess) {
            if (! filePicked) {
                basePage.filepicker.open();
            }
        } else {
            lastTab = activeTab;
        }
    }

    onCreationCompleted: {
        lastTab = tabFeed;
    }
}
