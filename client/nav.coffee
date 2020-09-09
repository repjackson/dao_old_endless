Router.route '/add', (->
    @layout 'layout'
    @render 'add'
    ), name:'add'



Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
    @autorun => Meteor.subscribe 'all_users'
    @autorun => Meteor.subscribe 'model_docs', 'tribe'

Template.nav.onRendered ->
    Meteor.setTimeout ->
        # $('.menu .item')
        #     .popup()
        $('.ui.left.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'overlay'
                exclusive:true
                duration:150
                scrollLock:false
            })
            .sidebar('attach events', '.toggle_sidebar')
    , 2000
    Meteor.setTimeout ->
        $('.ui.right.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'overlay'
                exclusive:true
                duration:150
                scrollLock:false
            })
            .sidebar('attach events', '.toggle_rightbar')
    , 2000

Template.right_sidebar.events
    'click .logout': ->
        Session.set 'logging_out', true
        Meteor.logout ->
            Session.set 'logging_out', false
            Router.go '/login'
    
    'click .toggle_nightmode': ->
        if Meteor.user().invert_class is 'invert'
            Meteor.users.update Meteor.userId(),
                $set:invert_class:''
        else
            Meteor.users.update Meteor.userId(),
                $set:invert_class:'invert'


Template.nav.helpers
    alert_toggle_class: ->
        if Session.get('viewing_alerts') then 'active' else ''

        
Template.leftbar_item.events
    'click .set_model': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', @model, ->
            Session.set 'loading', false

Template.nav.events
    'keydown .search_dao': (e,t)->
        search = $('.search_dao').val().toLowerCase().trim()
        # Session.set('query',search)
        if e.which is 13
            Router.go "/"
            selected_tags.push search
            Meteor.call 'call_wiki', search, ->
            Meteor.call 'search_reddit', selected_tags.array(), ->
            Session.set('query','')
            search = $('.search_dao').val('')
        if e.which is 8
            if search.legnth is 0
                selected_tags.pop()

    'click .set_post': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'post', ->
            Session.set 'loading', false

    'click .debit': ->
        new_debit_id =
            Docs.insert
                model:'debit'
                buyer_id:Meteor.userId()
                buyer_username:Meteor.user().username
                status:'started'
        Router.go "/debit/#{new_debit_id}/edit"
    'click .post': ->
        new_post_id =
            Docs.insert
                model:'post'
                source:'self'
                buyer_id:Meteor.userId()
                buyer_username:Meteor.user().username
        Router.go "/post/#{new_post_id}/edit"
    'click .alpha': ->
        new_alpha_id =
            Docs.insert
                model:'alpha'
                seller_id:Meteor.userId()
                seller_username:Meteor.user().username
        Router.go "/alpha/#{new_alpha_id}/edit"

    'click .toggle_admin': ->
        if 'admin' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'admin'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'admin'
    'click .toggle_dev': ->
        if 'dev' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'dev'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'dev'

    'click .view_profile': ->
        Meteor.call 'calc_user_points', Meteor.userId()
        
        
Template.topbar.onCreated ->
    @autorun => Meteor.subscribe 'my_received_messages'
    @autorun => Meteor.subscribe 'my_sent_messages'

Template.nav.helpers
    unread_count: ->
        Docs.find( 
            model:'message'
            recipient_id:Meteor.userId()
            read_ids:$nin:[Meteor.userId()]
        ).count()
Template.topbar.helpers
    recent_alerts: ->
        Docs.find 
            model:'message'
            recipient_id:Meteor.userId()
            read_ids:$nin:[Meteor.userId()]
        , sort:_timestamp:-1
        
Template.recent_alert.events
    'click .mark_read': (e,t)->
        # console.log @
        # console.log $(e.currentTarget).closest('.alert')
        # $(e.currentTarget).closest('.alert').transition('slide left')
        Docs.update @_id, 
            $addToSet:read_ids:Meteor.userId()
        # Meteor.setTimeout ->
        # , 500
        
Template.topbar.events
    'click .close_topbar': ->
        Session.set('viewing_alerts', false)

        
        
Template.left_sidebar.onCreated ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000

Template.left_sidebar.events
    'click .set_wikipedia': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'wikipedia', ->
            Session.set 'loading', false
    'click .set_reddit': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'reddit', ->
            Session.set 'loading', false

    'click .posts': ->
        Router.go '/'
        selected_models.clear()
        selected_models.push 'post'
        
    'click .top_earned': ->
        Router.go '/'
        selected_models.clear()
        selected_models.push 'post'
        Session.set('sort_key','total_points')
        Session.set('sort_direction',-1)
    'click .newest_posts': ->
        Router.go '/'
        selected_models.clear()
        selected_models.push 'post'
        Session.set('sort_key','_timestamp')
        Session.set('sort_direction',-1)
    'click .my_posts': ->
        Router.go '/'
        selected_models.clear()
        selected_models.push 'post'
        Session.set('sort_key','_timestamp')
        Session.set('sort_direction',-1)
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
    'click .toggle_dev': ->
        if 'dev' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'dev'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'dev'
                
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
