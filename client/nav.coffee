Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
    @autorun => Meteor.subscribe 'all_users'

Template.nav.onRendered ->
    Meteor.setTimeout ->
        # $('.menu .item')
        #     .popup()
        $('.ui.left.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'overlay'
                exclusive:true
                duration:250
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_sidebar')
    , 1000
    Meteor.setTimeout ->
        $('.ui.right.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'overlay'
                exclusive:true
                duration:250
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_rightbar')
    , 1000

Template.right_sidebar.events
    'click .logout': ->
        Session.set 'logging_out', true
        Meteor.logout ->
            Session.set 'logging_out', false
            Router.go '/login'

Template.nav.helpers
    alert_toggle_class: ->
        if Session.get('viewing_alerts') then 'active' else ''
Template.nav.events
    'click .alerts': ->
        Session.set('viewing_alerts', !Session.get('viewing_alerts'))
        
    'click .toggle_admin': ->
        if 'admin' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'admin'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'admin'
    'click .set_member': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'member', ->
            Session.set 'loading', false
    'click .set_shift': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'shift', ->
            Session.set 'loading', false
    'click .set_request': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'request', ->
            Session.set 'loading', false
    'click .set_offer': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'offer', ->
            Session.set 'loading', false
    'click .set_model': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'model', ->
            Session.set 'loading', false
    'click .set_rental': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'rental', ->
            Session.set 'loading', false
    'click .set_product': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'product', ->
            Session.set 'loading', false
    'click .set_event': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'event', ->
            Session.set 'loading', false
    'click .set_badge': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'badge', ->
            Session.set 'loading', false
    'click .set_location': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'location', ->
            Session.set 'loading', false
    'click .set_meal': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'meal', ->
            Session.set 'loading', false
    'click .set_project': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'project', ->
            Session.set 'loading', false
    'click .set_post': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'post', ->
            Session.set 'loading', false
    'click .add_gift': ->
        # user = Meteor.users.findOne(username:@username)
        new_gift_id =
            Docs.insert
                model:'gift'
                recipient_id: @_id
        Router.go "/debit/#{new_gift_id}/edit"

    'click .add_request': ->
        # user = Meteor.users.findOne(username:@username)
        new_id =
            Docs.insert
                model:'request'
                recipient_id: @_id
        Router.go "/request/#{new_id}/edit"


    'click .view_profile': ->
        Meteor.call 'calc_user_points', Meteor.userId()
        
        
Template.topbar.onCreated ->
    @autorun => Meteor.subscribe 'my_received_messages'
    @autorun => Meteor.subscribe 'my_sent_messages'

Template.topbar.helpers
    recent_alerts: ->
        Docs.find 
            model:'message'
            recipient_id:Meteor.userId()
        , srot:_timestamp:-1
Template.left_sidebar.events
    # 'click .toggle_sidebar': ->
    #     $('.ui.sidebar')
    #         .sidebar('setting', 'transition', 'push')
    #         .sidebar('toggle')
    'click .toggle_admin': ->
        if 'admin' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'admin'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'admin'
    'click .set_member': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'member', ->
            Session.set 'loading', false
    'click .set_shift': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'shift', ->
            Session.set 'loading', false
    'click .set_request': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'request', ->
            Session.set 'loading', false
    'click .set_model': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'model', ->
            Session.set 'loading', false
    'click .set_rental': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'rental', ->
            Session.set 'loading', false
    'click .set_product': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'product', ->
            Session.set 'loading', false
    'click .set_event': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'event', ->
            Session.set 'loading', false
    'click .set_badge': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'badge', ->
            Session.set 'loading', false
    'click .set_location': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'location', ->
            Session.set 'loading', false
    'click .set_meal': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'meal', ->
            Session.set 'loading', false
    'click .set_project': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'project', ->
            Session.set 'loading', false
    'click .add_gift': ->
        # user = Meteor.users.findOne(username:@username)
        new_gift_id =
            Docs.insert
                model:'gift'
                recipient_id: @_id
        Router.go "/debit/#{new_gift_id}/edit"

    'click .add_request': ->
        # user = Meteor.users.findOne(username:@username)
        new_id =
            Docs.insert
                model:'request'
                recipient_id: @_id
        Router.go "/request/#{new_id}/edit"

        