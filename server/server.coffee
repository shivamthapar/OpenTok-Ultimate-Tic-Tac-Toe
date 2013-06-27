Accounts.onCreateUser (options, user)->
	if options.profile
		options.profile.fbId = user.services.facebook.id
		options.profile.picture = "http://graph.facebook.com/" + user.services.facebook.id + "/picture/?type=large"
		options.profile.score = 0
		user.profile = options.profile
		addPlayerToDB user.profile
	return user

Accounts.loginServiceConfiguration.remove {
	service: "facebook"
}
Accounts.loginServiceConfiguration.insert {
	service: "facebook"
	appId: "576348209083716"
	secret: "3ff538796ddf79d584c88ec4484c7f34"
}

addPlayerToDB = (profile)->
	count = Players.find({fbId:profile.id},{}).count()
	if count > 0
		return
	Players.insert {fbId: profile.fbId, name: profile.name, picture: profile.picture, score: profile.score}
