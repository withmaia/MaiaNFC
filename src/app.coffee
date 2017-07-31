React = require 'react'
ReactNative = require 'react-native'
{AppRegistry, StyleSheet, Text, View, Image, Animated, DeviceEventEmitter} = ReactNative
Redux = require 'redux'
styles = require './styles'
colors = require './colors'
Spinner = require './spinner'
Icon = require './icon'
helpers = require './helpers'
fetch$ = require 'kefir-fetch'

initial_state =
    loading: true

combinedReducer = (state={}, action) ->
    console.log '[action]', action
    switch action.type
        when 'loading'
            {mime_type, payload} = action
            return Object.assign {}, state, {loading: true, mime_type, payload}
        when 'loaded'
            return Object.assign {}, state, {loading: false}, action.loaded
    return state

Store = Redux.createStore combinedReducer, initial_state

loaders =
    'maia/light': (light_name) ->
        fetch$ 'post', 'http://api.withmaia.com/maia:hue/toggleState.json', {body: {args: [light_name]}}
            .map (response) ->
                {value: if response.on then 'on' else 'off'}
    'maia/price': (market_name) ->
        fetch$ 'post', 'http://api.withmaia.com/price/getPrice.json', {body: {args: [market_name]}}

LightAction = ({light_name, value, loading}) ->
    <View style=styles.action>
        {if loading
            <Spinner />
        else if value == 'on'
            <Icon icon='lightbulbO' style={[styles.action_icon, {color: colors.yellow}]} />
        else
            <Icon icon='lightbulbO' style=styles.action_icon />
        }
        {if loading
            <Text style=styles.action_description>Toggling the {helpers.unslugify light_name}...</Text>
        else
            <Text style=styles.action_description>Turned {value} the {helpers.unslugify light_name}.</Text>
        }
    </View>

PriceAction = ({market_name, value, loading}) ->
    <View style=styles.action>
        {if loading
            <Spinner />
        else
            <Icon icon='bitcoin' style=styles.action_icon />
        }
        {if loading
            <Text style=styles.action_description>Loading...</Text>
        else
            <Text style=styles.action_description>{helpers.capitalize helpers.unslugify market_name} is ${value.toFixed 2}.</Text>
        }
    </View>

module.exports = class MaiaNFCNative extends React.Component
    constructor: ->
        console.log '[constructor]'
        @state = Store.getState()

    componentDidMount: ->
        @unsubscribe = Store.subscribe =>
            @setState Store.getState()

        {mime_type, payload} = @props
        @loadTag mime_type, payload

        DeviceEventEmitter.addListener 'new_tag', (new_tag) =>
            console.log '[newTag]', new_tag
            {mime_type, payload} = new_tag
            @loadTag mime_type, payload

    componentWillUnmount: ->
        @unsubscribe()

    loadTag: (mime_type, payload) ->
        Store.dispatch {type: 'loading', mime_type, payload}
        loaders[mime_type](payload)
            .onValue (loaded) ->
                Store.dispatch {type: 'loaded', loaded}

    render: ->
        <View style=styles.container>
            <Image source={require('../images/maia_logo.png')} />
            {switch @state.mime_type
                when 'maia/light'
                    <LightAction {...@state} light_name=@state.payload />
                when 'maia/price'
                    <PriceAction {...@state} market_name=@state.payload />
                else
                    <Text>?</Text>
            }
        </View>

MaiaNFCNative.defaultProps =
    # mime_type: 'maia/light'
    # payload: 'office_light'
    mime_type: 'maia/price'
    payload: 'btc'

