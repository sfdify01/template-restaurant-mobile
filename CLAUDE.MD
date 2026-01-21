Now in this project, we will use riverpod for state management (using latest version and latest syntax)
and for routing we will use auto_route (using latest version and latest syntax, this tool got very good syntax to reduce amount of code to maintain routing, please make use of and benefit of.)
we need to first init git and commit and push this repo:
https://github.com/sfdify01/shahirizada_fresh_market_mobile

The whole idea of this project is to make mobile version of this storefront meat market website so people can give order online as well. we use stripe connect infrastructure. here it is:
https://github.com/sfdify01/shahirizada_fresh_market
This above is a monorepo, where my frontend code, my supabase functions etc.

we as tabsy already created website+supabase, now time to make the mobile as well. so our business model is this and we already have website-supabase server up and working. everything there. u just need to generate flutter mobile app now.
Note: riverpod deprecated statenotifier class. dont use. instead now we have 'Notifier', 'AsyncNotifier', 'StreamNotifier' and their provider classes as well. Make sure using latest syntaxes.


We need to use dart_mappable for data models and keep data models identical with web.

https://github.com/sfdify01/shahirizada_fresh_market (monorepo)

https://github.com/sfdify01/shahirizada_fresh_market_mobile


NEVER TRY TO TAKE BUILD , I DONT WANT IT! USE DART ANALYZE OR FLUTTER ANALYZE WHATEVER TO FIGURE OUT ERRORS BUT THATS IT. DONT TAKE BUILD.