React = require 'react'
{Animated} = require 'react-native'
styles = require './styles'
Icon = require './icon'

spin_interpolation =
    inputRange: [0, 360]
    outputRange: ['0deg', '360deg']

module.exports = class Spinner extends React.Component
    constructor: ->
        @state = {spin: new Animated.Value(0)}

    componentDidMount: ->
        Animated.timing @state.spin, {toValue: 360, duration: 5000}
            .start()

    render: ->
        spin_transform = {transform: [{rotate: @state.spin.interpolate spin_interpolation}]}
        <Animated.View style={[styles.action_icon, spin_transform]}><Icon icon='circleONotch' /></Animated.View>

