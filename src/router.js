import Vue from 'vue'
import Router from 'vue-router'
import Owner from './components/Owner.vue'
import Stake from './components/Stake.vue'
import Vote from './components/Vote.vue'


Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/owner',
      name: 'Owner',
      component: Owner
    },
    {
      path: '/stake',
      name: 'Stake',
      component: Stake
    },
    {
      path: '/vote',
      name: 'Vote',
      component: Vote
    }
  ]
  }
)

