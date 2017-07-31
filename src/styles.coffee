{StyleSheet} = require 'react-native'
colors = require './colors'

module.exports = styles = StyleSheet.create
    container:
        flex: 1
        justifyContent: 'center'
        alignItems: 'stretch'
        backgroundColor: colors.purple

    logo:
        alignSelf: 'center'
        marginTop: 100

    spacer:
        flexGrow: 1

    animated_action:
        position: 'absolute'
        top: '50%'
        left: 20
        right: 20

    action:
        backgroundColor: colors.glass
        borderRadius: 5
        paddingLeft: 30
        paddingRight: 30
        paddingTop: 15
        paddingBottom: 15
        flexDirection: 'row'

    icon:
        fontSize: 20
        lineHeight: 25
        height: 25
        alignItems: 'center'

    action_icon:
        marginRight: 15

    action_description:
        fontSize: 20
        color: colors.white

    props:
        fontSize: 15

