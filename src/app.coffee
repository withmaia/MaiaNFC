React = require 'react'
ReactNative = require 'react-native'
{AppRegistry, StyleSheet, Text, View, Image, Animated} = ReactNative
styles = require './styles'
Spinner = require './spinner'

module.exports = class MaiaNFCNative extends React.Component
    render: ->
        props_string = JSON.stringify @props
        <View style=styles.container>
            <Image source={require('../images/maia_logo.png')} />
            <View style=styles.action>
                <Spinner />
                <Text style=styles.action_description>Turned off the office light.</Text>
            </View>
            <Text style=styles.props>{props_string}</Text>
        </View>

MaiaNFCNative.defaultProps =
    mime_type: 'maia/light'
    payload: 'office_light'

