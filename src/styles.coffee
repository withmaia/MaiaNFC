{StyleSheet} = require 'react-native'

colors =
    white: '#ffffff'
    purple: '#515CA0'
    glass: 'rgba(255, 255, 255, 0.1)'

module.exports = styles = StyleSheet.create
    container:
        flex: 1
        justifyContent: 'center'
        alignItems: 'center'
        backgroundColor: colors.purple

    action:
        backgroundColor: colors.glass
        borderRadius: 5
        paddingLeft: 30
        paddingRight: 30
        paddingTop: 15 + 5
        paddingBottom: 15
        marginTop: 30
        flexDirection: 'row'

    action_icon:
        marginRight: 15

    action_description:
        fontSize: 20
        textAlign: 'center'
        color: colors.white

    props:
        fontSize: 15


