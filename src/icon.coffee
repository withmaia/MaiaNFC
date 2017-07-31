React = require 'react'
{Text} = require 'react-native'
FontAwesome = require 'react-native-fontawesome'
FA = FontAwesome.default
Icons = FontAwesome.Icons
styles = require './styles'

module.exports = ({icon, style}) ->
    <Text style={[styles.icon, style]}><FA>{Icons[icon]}</FA></Text>
