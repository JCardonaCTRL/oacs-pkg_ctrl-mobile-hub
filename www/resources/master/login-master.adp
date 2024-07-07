<master src="/www/site-master">
<if @doc@ defined><property name="&doc">doc</property></if>
<if @body@ defined><property name="&body">body</property></if>
<if @head@ not nil><property name="head">@head;noquote@</property></if>
<if @focus@ not nil><property name="focus">@focus;noquote@</property></if>
<property name="skip_link">@skip_link;noquote@</property>

<style>
body{background: url('/resources/images/bg_web.png');background-repeat: no-repeat;background-size: 100%;background-position: center top;min-height:2080px;font-size:2.5em;} 
.margintop{margin-top:50px;}
#register-login > a {display:none;!important;}
.btn-lg{font-size:1.2em;text-align:center;}
input[type="text"], input[type="password"]{width:80%;height:1.5em;border:1px solid #666;margin-right:2em;font-size:1em;}
input[type="checkbox"]{height:1.5em;width:1.5em;position:relative;top:.5em;}
.margin-form .form-item-wrapper .form-label {float: left;text-align: right;display: block;width: 20%;}
.margin-form .form-item-wrapper .form-widget, .margin-form .form-button, .margin-form .form-help-text {display: block;margin-left:2em;}
.form-button{text-align:center;margin:1em auto;}
</style>

<div class="container">
  <div class="row">
    <div class="offset-sm-2 col-sm-8 text-center">
      <img class="img-responsive" src="/resources/images/oacshub_512x512.png" height="180"/>
    </div>
  </div>
  <div class="row">
    <div class="col-sm-12 margintop">
            <slave />
    </div>
  </div>
</div>

