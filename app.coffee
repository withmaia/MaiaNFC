React = require 'react'
ReactNative = require 'react-native'
{AppRegistry, StyleSheet, Text, View, Image} = ReactNative

purple = '#515CA0'

styles = StyleSheet.create
    container:
        flex: 1
        justifyContent: 'center'
        alignItems: 'center'
        backgroundColor: purple

    action:
        backgroundColor: 'rgba(255, 255, 255, 0.1)'
        borderRadius: 5
        paddingLeft: 30
        paddingRight: 30
        paddingTop: 20
        paddingBottom: 20
        marginTop: 30
        flexDirection: 'row'

    action_icon:
        marginRight: 15

    action_description:
        fontSize: 20
        textAlign: 'center'
        color: '#ffffff'

    props:
        fontSize: 15

# Tag = 

module.exports = class MaiaNFCNative extends React.Component
    render: ->
        props_string = JSON.stringify @props
        <View style=styles.container>
            <Image source={require('./images/maia_logo.png')} />
            <View style=styles.action>
                <Image source={require('./images/lightbulb_false.png')} style=styles.action_icon />
                <Text style=styles.action_description>Turned off the office light.</Text>
            </View>
            <Text style=styles.props>{props_string}</Text>
        </View>
