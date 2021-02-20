<template>
<div id="app">
  <keep-alive>
    <router-view :key="key" />
  </keep-alive>
</div>
</template>

<script>
export default {
  name: 'app',
  data(){
    return {
    }
	},
	computed:{
    key(){
      return this.$route.path + Math.random();
    }
	}
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  padding: 10px 200px;
}

body {
  margin: 10px;
}

.nav {
  margin: 10px;

}

.nav a {
  padding: 10px;
  font-size: 17px;
}

.margining {
  margin: 10px;
  font-size: 18px;
}

.margining p {
    font-size: 18px;
}

.input-btns {
  display: flex;
  flex-direction: row;
  justify-content: center;
  margin: 10px;
}

.row-center {
  display: flex;
  margin-top: 4px;
  font-size: 20px;
  flex-direction: row;
  justify-content: center;
}

.row-center div {
  padding: 2px;
}

.row-center input {
  font-size: 21px;
  margin: 2px;
}

.row-center button {
  font-size: 17px;
}

.content {
  padding-top: 10px;
  padding-left: 14px;
  padding-right: 14px;
  margin: 8px;
}


</style>
