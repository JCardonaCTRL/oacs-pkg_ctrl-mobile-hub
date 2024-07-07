<master src="/packages/ctrl-mobile-hub/www/resources/master/login-master" >
  <property name="focus">@focus;literal@</property>
  <property name="doc(title)">#acs-subsite.Log_In#</property>
  <property name="context">{#acs-subsite.Log_In#}</property>

<div class="container">
<formtemplate id="login">
  <br />
  <div class="form-row center">

    <div class="form-group row">
      <div class="col-sm-4"><label for="email" class="pull-right">Email:</label></div>
      <div class="col-sm-8">
        <formwidget id="email">
        <div class="form-error"><formerror id="email"></formerror></div>
      </div>
    </div>
    <br />
    <div class="form-group row">
      <div class="col-sm-4"><label for="password" class="pull-right">Password:</label></div>
      <div class="col-sm-8">
        <formwidget id="password">
        <div class="form-error"><formerror id="password"></formerror></div>
      </div>
    </div>
    <br />
    <div class="form-group row">
      <div class="offset-sm-2 col-sm-8">
        <input type="submit" class="btn btn-primary btn-lg btn-block center" name="formbutton:ok" value="#acs-subsite.Log_In#">
      </div>
    </div>

  </div>
</formtemplate>
</div>
