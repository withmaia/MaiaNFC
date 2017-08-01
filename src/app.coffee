React = require 'react'
ReactNative = require 'react-native'
{AppRegistry, Animated, StyleSheet, Text, View, ScrollView, Image, DeviceEventEmitter} = ReactNative
Redux = require 'redux'
Kefir = require 'kefir'
fetch$ = require 'kefir-fetch'
update = require 'immutability-helper'

styles = require './styles'
colors = require './colors'
Spinner = require './spinner'
Icon = require './icon'
helpers = require './helpers'

initial_state =
    tags: {}

collectionReducer = (state={}, action) ->
    console.log '[action]', action
    console.log '[state]', state
    switch action.type
        when 'loading'
            {id, mime_type, payload} = action
            new_tag = {id, mime_type, payload, loading: true}
            console.log '[new_tag]', new_tag
            create_tag = {}
            create_tag[new_tag.id] = new_tag
            the_update = {$merge: create_tag}
            if Object.keys(state).length > 1
                the_update.$unset = [Object.keys(state)[0]]
            return update state, the_update
        when 'loaded'
            update_tag = {}
            updated_tag = Object.assign {}, action.loaded, {loading: false}
            update_tag[action.id] = {$merge: updated_tag}
            console.log '[update_tag]', update_tag
            return update state, update_tag
    return state

combinedReducer = Redux.combineReducers
    tags: collectionReducer

Store = Redux.createStore combinedReducer, initial_state

loaders =
    'maia/light': (light_name) ->
        fetch$ 'post', 'http://api.withmaia.com/maia:hue/toggleState.json', {body: {args: [light_name]}}
            .map (response) ->
                {value: if response.on then 'on' else 'off'}
    'maia/price': (market_name) ->
        Kefir.zip([
            fetch$ 'post', 'http://api.withmaia.com/price/getPrice.json', {body: {args: [market_name]}}
            fetch$ 'get', 'https://blockexplorer.com/api/addr/1sproFExWZY5GnyjHpB6kVFznDTpFQ7gm'
        ]).map ([price_response, wallet_response]) ->
            {value: price_response.value, balance: wallet_response.balance}

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

PriceAction = ({market_name, value, balance, loading}) ->
    console.log '[PriceAction]', {value, balance}
    <View style=styles.action>
        {if loading
            <Spinner />
        else
            <Icon icon='bitcoin' style=styles.action_icon />
        }
        {if loading
            <Text style=styles.action_description>Loading...</Text>
        else
            <Text style=styles.action_description>{helpers.capitalize helpers.unslugify market_name} is ${value.toFixed 2} on GDAX. Your balance is ฿{balance.toFixed 2} or ${(balance * value).toFixed 2}.</Text>
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
        id = helpers.randomString()
        Store.dispatch {type: 'loading', id, mime_type, payload}
        loaders[mime_type](payload)
            .onValue (loaded) ->
                Store.dispatch {type: 'loaded', id, loaded}

    render: ->
        <View style=styles.container>
            <Image source={require('../images/maia_logo.png')} style=styles.logo />
            <View style=styles.spacer />
            {Object.entries(@state.tags).map ([tag_id, tag], i) =>
                @renderAnimatedTag tag_id, tag, i
            }
        </View>

    renderAnimatedTag: (tag_id, tag, i) ->
        if i == 0 and Object.keys(@state.tags).length > 1
            return <FadeOut key="fade:#{tag_id}">{@renderTag tag_id, tag}</FadeOut>
        else
            return <FadeIn key="fade:#{tag_id}">{@renderTag tag_id, tag}</FadeIn>

    renderTag: (tag_id, tag) ->
        switch tag.mime_type
            when 'maia/light'
                <LightAction {...tag} light_name=tag.payload key=tag_id />
            when 'maia/price'
                <PriceAction {...tag} market_name=tag.payload key=tag_id />
            else
                <Text key=tag_id>?</Text>

# ------------------------------------------------------------------------------

ANIMATION_DURATION = 500

fade_out_interpolation =
    inputRange: [0, 1]
    outputRange: [1, 0]

fade_in_interpolation =
    inputRange: [0, 1]
    outputRange: [0, 1]

translate_up_interpolation =
    inputRange: [0, 1]
    outputRange: [0, -100]

translate_down_interpolation =
    inputRange: [0, 1]
    outputRange: [50, 0]

scale_out_interpolation =
    inputRange: [0, 1]
    outputRange: [1, 0.9]

class FadeOut extends React.Component
    constructor: ->
        @state = {fade: new Animated.Value(0)}

    componentDidMount: ->
        Animated.timing @state.fade, {toValue: 1, duration: ANIMATION_DURATION}
            .start()

    render: ->
        fade_style = {
            opacity: @state.fade.interpolate fade_out_interpolation
            transform: [
                {translateY: @state.fade.interpolate translate_up_interpolation}
                {scale: @state.fade.interpolate scale_out_interpolation}
            ]
        }
        <Animated.View style={[styles.animated_action, fade_style]}>
            {@props.children}
        </Animated.View>

class FadeIn extends React.Component
    constructor: ->
        @state = {fade: new Animated.Value(0)}

    componentDidMount: ->
        Animated.timing @state.fade, {toValue: 1, duration: ANIMATION_DURATION}
            .start()

    render: ->
        fade_style = {
            opacity: @state.fade.interpolate fade_in_interpolation
            transform: [
                {translateY: @state.fade.interpolate translate_down_interpolation}
            ]
        }
        <Animated.View style={[styles.animated_action, fade_style]}>
            {@props.children}
        </Animated.View>

MaiaNFCNative.defaultProps =
    # mime_type: 'maia/light'
    # payload: 'office_light'
    mime_type: 'maia/price'
    payload: 'btc'

