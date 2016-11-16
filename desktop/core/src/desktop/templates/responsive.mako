## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
  from desktop import conf
  from desktop.views import _ko
  from django.utils.translation import ugettext as _
  from desktop.lib.i18n import smart_unicode
  from desktop.views import login_modal
  from metadata.conf import has_optimizer
%>

<%namespace name="assist" file="/assist.mako" />
<%namespace name="hueIcons" file="/hue_icons.mako" />

<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta charset="utf-8">
  <title>Hue</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <link rel="icon" type="image/x-icon" href="${ static('desktop/art/favicon.ico') }"/>
  <meta name="description" content="">
  <meta name="author" content="">

  <link href="${ static('desktop/ext/css/bootplus.css') }" rel="stylesheet">
  <link href="${ static('desktop/ext/css/font-awesome.min.css') }" rel="stylesheet">
  <link href="${ static('desktop/css/responsive.css') }" rel="stylesheet">
  <link href="${ static('desktop/css/jquery-ui.css') }" rel="stylesheet">

  <!--[if lt IE 9]>
  <script type="text/javascript">
    if (document.documentMode && document.documentMode < 9) {
      location.href = "${ url('desktop.views.unsupported') }";
    }
  </script>
  <![endif]-->

  <script type="text/javascript" charset="utf-8">
    // check if it's a Firefox < 7
    var _UA = navigator.userAgent.toLowerCase();
    for (var i = 1; i < 7; i++) {
      if (_UA.indexOf("firefox/" + i + ".") > -1) {
        location.href = "${ url('desktop.views.unsupported') }";
      }
    }

    // check for IE document modes
    if (document.documentMode && document.documentMode < 9) {
      location.href = "${ url('desktop.views.unsupported') }";
    }

    var LOGGED_USERNAME = '${ user.username }';
    var IS_S3_ENABLED = '${ is_s3_enabled }' === 'True';
    var HAS_OPTIMIZER = '${ has_optimizer() }' === 'True';

    ApiHelperGlobals = {
      i18n: {
        errorLoadingDatabases: '${ _('There was a problem loading the databases') }',
        errorLoadingTablePreview: '${ _('There was a problem loading the preview') }'
      },
      user: '${ user.username }'
    }
  </script>
</head>

<body>

${ hueIcons.symbols() }

<div class="main-page">
  <div class="top-nav">
    <div class="top-nav-left">
      <a class="hamburger hamburger-hue pull-left" type="button">
      <span class="hamburger-box">
        <span class="hamburger-inner"></span>
      </span>
      </a>
      <a class="brand nav-tooltip pull-left" title="${_('Homepage')}" rel="navigator-tooltip" href="/home"><img src="${ static('desktop/art/hue-logo-mini-white.png') }" data-orig="${ static('desktop/art/hue-logo-mini-white.png') }" data-hover="${ static('desktop/art/hue-logo-mini-white-hover.png') }"/></a>
      <div class="compose-action btn-group">
        <button class="btn">${ _('Compose') }</button>
        <button class="btn dropdown-toggle" data-toggle="dropdown">
          <span class="caret"></span>
        </button>
        <ul class="dropdown-menu">
          % if 'beeswax' in apps:
            <li><a href="${ url('notebook:editor') }?type=hive"><img src="${ static(apps['beeswax'].icon_path) }" class="app-icon"/> ${_('Hive')}</a></li>
          % endif
          % if 'impala' in apps: ## impala requires beeswax anyway
            <li><a href="${ url('notebook:editor') }?type=impala"><img src="${ static(apps['impala'].icon_path) }" class="app-icon"/> ${_('Impala')}</a></li>
          % endif
          % if 'search' in apps:
            <li><a href="${ url('search:new_search') }"><img src="${ static('search/art/icon_search_48.png') }" class="app-icon"/> ${ _('Dashboard') }</a></li>
          % endif
          % if 'oozie' in apps:
          % if not user.has_hue_permission(action="disable_editor_access", app="oozie") or user.is_superuser:
            <li class="dropdown-submenu">
              <a title="${_('Schedule with Oozie')}" rel="navigator-tooltip" href="#"><img src="${ static('oozie/art/icon_oozie_editor_48.png') }" class="app-icon" /> ${ _('Workflows') }</a>
              <ul class="dropdown-menu">
                <li><a href="${url('oozie:list_editor_workflows')}"><img src="${ static('oozie/art/icon_oozie_workflow_48.png') }" class="app-icon"/> ${_('Workflows')}</a></li>
                <li><a href="${url('oozie:list_editor_coordinators')}"><img src="${ static('oozie/art/icon_oozie_coordinator_48.png') }" class="app-icon" /> ${_('Coordinators')}</a></li>
                <li><a href="${url('oozie:list_editor_bundles')}"><img src="${ static('oozie/art/icon_oozie_bundle_48.png') }" class="app-icon" /> ${_('Bundles')}</a></li>
              </ul>
            </li>
          % endif
          % endif
          % if len(interpreters) > 0:
          <li class="divider"></li>
          <li class="dropdown-submenu">
            <a title="${_('More...')}" rel="navigator-tooltip" href="#"><span class="dropdown-no-icon">${ _('More') }</span></a>
            <ul class="dropdown-menu">
              % for interpreter in interpreters:
                % if interpreter['name'] != 'Hive' and interpreter['name'] != 'Impala':
                <li><a href="${ url('notebook:editor') }?type=${ interpreter['type'] }"><span class="dropdown-no-icon">${ interpreter['name'] }</span></a></li>
                % endif
              % endfor
              % if user.is_superuser:
                <li class="divider"></li>
                <li><a href="gethue.com" class="dropdown-no-icon">${ _('Add more...') }</a></li>
              % endif
            </ul>
          </li>
          % endif
        </ul>
      </div>
    </div>
    <div class="top-nav-middle">
      <div class="search-container">
        <input placeholder="${ _('Search all data and saved documents...') }" type="text"
          data-bind="autocomplete: {
              source: searchAutocompleteSource,
              itemTemplate: 'nav-search-autocomp-item',
              noMatchTemplate: 'nav-search-autocomp-no-match',
              classPrefix: 'nav-',
              showOnFocus: true,
              onEnter: performSearch,
              reopenPattern: /.*:$/
            },
            hasFocus: searchHasFocus,
            clearable: { value: searchInput, onClear: function () { searchActive(false); huePubSub.publish('autocomplete.close'); } },
            textInput: searchInput,
            valueUpdate: 'afterkeydown'"
        >
        <a class="inactive-action" data-bind="click: performSearch"><i class="fa fa-search" data-bind="css: { 'blue': searchHasFocus() || searchActive() }"></i></a>
      </div>
    </div>
    <div class="top-nav-right">
      % if user.is_authenticated() and section != 'login':

        <div class="compose-action btn-group">
          <button class="btn">${user.username}</button>
          % if user.is_superuser:
            <button class="btn dropdown-toggle" data-toggle="dropdown">
              <span class="caret"></span>
            </button>
            <ul class="dropdown-menu" >
              <li><a href="${ url('useradmin.views.list_users') }"><i class="fa fa-group"></i> ${_('Manage Users')}</a></li>
              <li><a href="${ url('useradmin.views.list_permissions') }"><i class="fa fa-key"></i> ${_('Set Permissions')}</a></li>
              <li><a href="/about"><span class="dropdown-no-icon">${_('Help')}</span></a></li>
              <li><a href="/about"><span class="dropdown-no-icon">${_('About Hue')}</span></a></li>
              <li class="divider"></li>
              <li><a title="${_('Sign out')}" href="/accounts/logout/"><i class="fa fa-sign-out"></i> ${ _('Sign out') }</a></li>
            </ul>
          % endif
        </div>

        <div class="compose-action btn-group">
          <button class="btn" title="${_('Running jobs and workflows')}" >${ _('Jobs') } <div class="jobs-badge">20</div></button>
          <button class="btn dropdown-toggle" data-bind="toggle: jobsPanelVisible">
            <span class="caret"></span>
          </button>
        </div>
        <div class="jobs-panel" data-bind="visible: jobsPanelVisible" style="display: none;">
          <span style="font-size: 15px; font-weight: 300">${_('Workflows')} (20)</span>
        </div>
      % endif
    </div>
  </div>

  <div class="content-wrapper">
    <div class="left-nav">
      <ul class="left-nav-menu">
        <li class="header">&nbsp;</li>
        <li class="header">Applications</li>
        <li><a href="javascript: void(0);">Reporter</a></li>
        <li><a href="javascript: void(0);">Hive</a></li>
        <li><a href="javascript: void(0);">Impala</a></li>
        <li><a href="javascript: void(0);">Dashboards</a></li>
        <li><a href="javascript: void(0);">Oozie</a></li>
        <li><a href="javascript: void(0);">Custom App 1</a></li>
        <li><a href="javascript: void(0);">Custom App 2</a></li>
        <li><a href="javascript: void(0);">Custom App 3</a></li>
        <li class="header">&nbsp;</li>
        <li class="header">Browse</li>
        <li><a href="javascript: void(0);">Metastore</a></li>
        <li><a href="javascript: void(0);">Indexes</a></li>
        <li><a href="javascript: void(0);">Job Browser</a></li>
        <li><a href="javascript: void(0);">File Browser</a></li>
        <li><a href="javascript: void(0);">HBase</a></li>
        <li><a href="javascript: void(0);">Security</a></li>
      </ul>
    </div>

##     <div style="position: fixed; bottom: 0; left: 0">
##       Create Table<br/>
##       Import File<br/>
##       Import Queries<br/>
##       [+]
##     </div>

    <div class="left-panel" data-bind="css: { 'side-panel-closed': !leftAssistVisible() }">
      <a href="javascript:void(0);" style="z-index: 1000; display: none;" title="${_('Show Assist')}" class="pointer side-panel-toggle show-left-side-panel" data-bind="visible: ! leftAssistVisible(), toggle: leftAssistVisible"><i class="fa fa-chevron-right"></i></a>
      <a href="javascript:void(0);" style="display: none;" title="${_('Hide Assist')}" class="pointer side-panel-toggle hide-left-side-panel" data-bind="visible: leftAssistVisible, toggle: leftAssistVisible"><i class="fa fa-chevron-left"></i></a>
      <!-- ko if: leftAssistVisible -->
      <div class="assist" data-bind="component: {
          name: 'assist-panel',
          params: {
            user: '${user.username}',
            sql: {
              sourceTypes: [{
                name: 'hive',
                type: 'hive'
              }],
              navigationSettings: {
                openItem: false,
                showStats: true
              }
            },
            visibleAssistPanels: ['sql']
          }
        }"></div>
      <!-- /ko -->
    </div>

    <div id="leftResizer" class="resizer" data-bind="visible: leftAssistVisible(), splitFlexDraggable : {
      containerSelector: '.content-wrapper',
      sidePanelSelector: '.left-panel',
      sidePanelVisible: leftAssistVisible,
      orientation: 'left',
      onPosition: function() { huePubSub.publish('split.draggable.position') }
    }"><div class="resize-bar">&nbsp;</div></div>


    <div class="page-content">
      Load
      <a href="#" data-bind="click: function(){ currentApp('editor') }">editor</a> |
      <a href="#" data-bind="click: function(){ currentApp('metastore') }">metastore</a> |
      <a href="#" data-bind="click: function(){ currentApp('search') }">search</a>

      <!-- ko if: isLoadingEmbeddable -->
      <i class="fa fa-spinner fa-spin"></i>
      <!-- /ko -->
      <div id="embeddable"></div>
    </div>

    <div id="rightResizer" class="resizer" data-bind="visible: rightAssistVisible(), splitFlexDraggable : {
      containerSelector: '.content-wrapper',
      sidePanelSelector: '.right-panel',
      sidePanelVisible: rightAssistVisible,
      orientation: 'right',
      onPosition: function() { huePubSub.publish('split.draggable.position') }
    }"><div class="resize-bar">&nbsp;</div></div>

    <div class="right-panel" data-bind="css: { 'side-panel-closed': !rightAssistVisible() }">
      <a href="javascript:void(0);" style="z-index: 1000; display: none;" title="${_('Show Assist')}" class="pointer side-panel-toggle show-right-side-panel" data-bind="visible: ! rightAssistVisible(), toggle: rightAssistVisible"><i class="fa fa-chevron-left"></i></a>
      <a href="javascript:void(0);" style="display: none;" title="${_('Hide Assist')}" class="pointer side-panel-toggle hide-right-side-panel" data-bind="visible: rightAssistVisible, toggle: rightAssistVisible"><i class="fa fa-chevron-right"></i></a>
      <div style="position: absolute; top: 15px; bottom: 0; left: 0; right: 0;" data-bind="component: { name: 'right-assist-panel' }"></div>
    </div>
  </div>
</div>

<script src="${ static('desktop/ext/js/jquery/jquery-2.2.3.min.js') }"></script>
<script src="${ static('desktop/js/hue.utils.js') }"></script>
<script src="${ static('desktop/ext/js/bootstrap.min.js') }"></script>
<script src="${ static('desktop/ext/js/moment-with-locales.min.js') }"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery.total-storage.min.js') }"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery.cookie.js') }"></script>

<script src="${ static('desktop/ext/js/jquery/plugins/jquery.basictable.min.js') }"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery-ui-1.10.4.custom.min.js') }"></script>

<script src="${ static('desktop/js/jquery.nicescroll.js') }"></script>

<script src="${ static('desktop/js/jquery.hdfsautocomplete.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/js/jquery.filechooser.js') }"></script>
<script src="${ static('desktop/js/jquery.selector.js') }"></script>
<script src="${ static('desktop/js/jquery.delayedinput.js') }"></script>
<script src="${ static('desktop/js/jquery.rowselector.js') }"></script>
<script src="${ static('desktop/js/jquery.notify.js') }"></script>
<script src="${ static('desktop/js/jquery.titleupdater.js') }"></script>
<script src="${ static('desktop/js/jquery.horizontalscrollbar.js') }"></script>
<script src="${ static('desktop/js/jquery.tablescroller.js') }"></script>
<script src="${ static('desktop/js/jquery.tableextender.js') }"></script>
<script src="${ static('desktop/js/jquery.tableextender2.js') }"></script>

<script src="${ static('desktop/ext/js/knockout.min.js') }"></script>
<script src="${ static('desktop/js/apiHelper.js') }"></script>
<script src="${ static('desktop/js/ko.charts.js') }"></script>
<script src="${ static('desktop/ext/js/knockout-mapping.min.js') }"></script>
<script src="${ static('desktop/ext/js/knockout-sortable.min.js') }"></script>
<script src="${ static('desktop/js/ko.editable.js') }"></script>
<script src="${ static('desktop/js/ko.hue-bindings.js') }"></script>
<script src="${ static('desktop/js/jquery.scrollup.js') }"></script>
<script src="${ static('desktop/js/sqlFunctions.js') }"></script>

${ assist.assistJSModels() }

${ assist.assistPanel() }

<!-- TODO: Put right assist inside assist.mako? -->
<script type="text/html" id="right-assist-template">
  <div style="height: 100%; width: 100%; overflow-x: hidden; position: relative;" data-bind="niceScroll">
    <div class="assist-function-type-switch" data-bind="foreach: availableTypes">
      <!-- ko if: $data === $parent.activeType() -->
      <span style="font-weight: 600;" data-bind="text: $data"></span>
      <!-- /ko -->
      <!-- ko ifnot: $data === $parent.activeType() -->
      <a class="black-link" href="javascript:void(0);" data-bind="click: function () { $parent.activeType($data); }, text: $data"></a>
      <!-- /ko -->
    </div>
    <ul class="assist-function-categories" data-bind="foreach: activeCategories">
      <li>
        <a class="black-link" href="javascript: void(0);" data-bind="toggle: open"><i class="fa fa-fw" data-bind="css: { 'fa-chevron-right': !open(), 'fa-chevron-down': open }"></i> <span data-bind="text: name"></span></a>
        <ul class="assist-functions" data-bind="slideVisible: open, foreach: functions">
          <li>
            <a class="assist-field-link" href="javascript: void(0);" data-bind="toggle: open, text: signature"></a>
            <div data-bind="slideVisible: open, text: description"></div>
          </li>
        </ul>
      </li>
    </ul>
  </div>
</script>

<script type="text/javascript" charset="utf-8">
  (function () {
    function RightAssist(params) {
      var self = this;
      self.categories = {};

      self.activeType = ko.observable();
      self.availableTypes = ['hive', 'impala'];

      self.initSqlFunctions('hive');
      self.initSqlFunctions('impala');

      self.activeCategories = ko.observable();

      self.activeType.subscribe(function (newValue) {
        self.activeCategories(self.categories[newValue]);
      });

      self.activeType(self.availableTypes[0]);
    }

    RightAssist.prototype.initSqlFunctions = function (dialect) {
      var self = this;
      self.categories[dialect] = [];
      SqlFunctions.CATEGORIZED_FUNCTIONS[dialect].forEach(function (category) {
        self.categories[dialect].push({
          name: category.name,
          open: ko.observable(false),
          functions: $.map(category.functions, function(fn) {
            return {
              signature: fn.signature,
              open: ko.observable(false),
              description: fn.description
            }
          })
        })
      });
    };

    ko.components.register('right-assist-panel', {
      viewModel: RightAssist,
      template: { element: 'right-assist-template' }
    });
  })();
</script>

<script type="text/javascript" charset="utf-8">

  $(document).ready(function () {
    var options = {
      user: '${ user.username }',
      i18n: {
        errorLoadingDatabases: "${ _('There was a problem loading the databases') }"
      }
    };

    (function () {
      var OnePageViewModel = function () {
        var self = this;

        self.EMBEDDABLE_PAGE_URLS = {
          editor: '/notebook/editor_embeddable',
          metastore: '/metastore/tables/?is_embeddable=true',
          search: '/search/embeddable?collection=4'
        };

        self.embeddable_cache = {};

        self.currentApp = ko.observable();
        self.isLoadingEmbeddable = ko.observable(false);

        self.currentApp.subscribe(function(newVal){
          self.isLoadingEmbeddable(true);
          if (typeof self.embeddable_cache[newVal] === 'undefined'){
            $.ajax({
              url: self.EMBEDDABLE_PAGE_URLS[newVal],
              beforeSend:function (xhr) {
                xhr.setRequestHeader('X-Requested-With', 'Hue');
              },
              dataType:'html',
              success:function (response) {
                // TODO: remove the next lines
                // hack to avoid css caching for development
                var r = $(response);
                r.find('link').each(function(){ $(this).attr('href', $(this).attr('href') + '?' + Math.random()) });
                self.embeddable_cache[newVal] = r;
                $('#embeddable').html(r);
                self.isLoadingEmbeddable(false);
              }
            });
          } else {
            $('#embeddable').html(self.embeddable_cache[newVal]);
            self.isLoadingEmbeddable(false);
          }
        });

        if (window.location.getParameter('editor') !== '' || window.location.getParameter('type') !== ''){
          self.currentApp('editor');
        }

        huePubSub.subscribe('switch.app', function (name) {
          console.log(name);
          self.currentApp(name);
        });
      };

      ko.applyBindings(new OnePageViewModel(), $('.page-content')[0]);
    })();


    (function () {
      function SidePanelViewModel () {
        var self = this;
        self.apiHelper = ApiHelper.getInstance();
        self.leftAssistVisible = ko.observable();
        self.rightAssistVisible = ko.observable();
        self.apiHelper.withTotalStorage('assist', 'left_assist_panel_visible', self.leftAssistVisible, true);
        self.apiHelper.withTotalStorage('assist', 'right_assist_panel_visible', self.rightAssistVisible, true);
      }

      var sidePanelViewModel = new SidePanelViewModel();
      ko.applyBindings(sidePanelViewModel, $('.left-panel')[0]);
      ko.applyBindings(sidePanelViewModel, $('#leftResizer')[0]);
      ko.applyBindings(sidePanelViewModel, $('#rightResizer')[0]);
      ko.applyBindings(sidePanelViewModel, $('.right-panel')[0]);
    })();

    (function () {
      function TopNavViewModel () {
        var self = this;
        self.apiHelper = ApiHelper.getInstance();
        self.searchActive = ko.observable(false);
        self.searchHasFocus = ko.observable(false);
        self.searchInput = ko.observable();
        self.jobsPanelVisible = ko.observable(false);

        // TODO: Extract to common module (shared with nav search autocomplete)
        var SEARCH_FACET_ICON = 'fa-tags';
        var SEARCH_TYPE_ICONS = {
          'DATABASE': 'fa-database',
          'TABLE': 'fa-table',
          'VIEW': 'fa-eye',
          'FIELD': 'fa-columns',
          'PARTITION': 'fa-th',
          'SOURCE': 'fa-server',
          'OPERATION': 'fa-cogs',
          'OPERATION_EXECUTION': 'fa-cog',
          'DIRECTORY': 'fa-folder-o',
          'FILE': 'fa-file-o',
          'SUB_OPERATION': 'fa-code-fork',
          'COLLECTION': 'fa-search',
          'HBASE': 'fa-th-large',
          'HUE': 'fa-file-o'
        };

        self.searchAutocompleteSource = function (request, callback) {
          // TODO: Extract complete contents to common module (shared with nav search autocomplete)
          var facetMatch = request.term.match(/([a-z]+):\s*(\S+)?$/i);
          var isFacet = facetMatch !== null;
          var partialMatch = isFacet ? null : request.term.match(/\S+$/);
          var partial = isFacet && facetMatch[2] ? facetMatch[2] : (partialMatch ? partialMatch[0] : '');
          var beforePartial = request.term.substring(0, request.term.length - partial.length);

          self.apiHelper.globalSearchAutocomplete({
            query:  request.term,
            successCallback: function (data) {
              var values = [];
              var facetPartialRe = new RegExp(partial.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"), 'i'); // Protect for 'tags:*axe'

              if (typeof data.resultsHuedocuments !== 'undefined') {
                data.resultsHuedocuments.forEach(function (result) {
                  values.push({ data: { label: result.hue_name, icon: SEARCH_TYPE_ICONS[result.type],  description: result.hue_description }, value: beforePartial + result.originalName });
                });
              }
              if (values.length > 0) {
                values.push({ divider: true });
              }

              if (isFacet && typeof data.facets !== 'undefined') { // Is typed facet, e.g. type: type:bla
                var facetInQuery = facetMatch[1];
                if (typeof data.facets[facetInQuery] !== 'undefined') {
                  $.map(data.facets[facetInQuery], function (count, value) {
                    if (facetPartialRe.test(value)) {
                      values.push({ data: { label: facetInQuery + ':' + value, icon: SEARCH_FACET_ICON, description: count }, value: beforePartial + value})
                    }
                  });
                }
              } else {
                if (typeof data.facets !== 'undefined') {
                  Object.keys(data.facets).forEach(function (facet) {
                    if (facetPartialRe.test(facet)) {
                      if (Object.keys(data.facets[facet]).length > 0) {
                        values.push({ data: { label: facet + ':', icon: SEARCH_FACET_ICON, description: $.map(data.facets[facet], function (key, value) { return value + ' (' + key + ')'; }).join(', ') }, value: beforePartial + facet + ':'});
                      } else { // Potential facet from the list
                        values.push({ data: { label: facet + ':', icon: SEARCH_FACET_ICON, description: '' }, value: beforePartial + facet + ':'});
                      }
                    } else if (partial.length > 0) {
                      Object.keys(data.facets[facet]).forEach(function (facetValue) {
                        if (facetValue.indexOf(partial) !== -1) {
                          values.push({ data: { label: facet + ':' + facetValue, icon: SEARCH_FACET_ICON, description: facetValue }, value: beforePartial + facet + ':' + facetValue });
                        }
                      });
                    }
                  });
                }
              }

              if (values.length > 0) {
                values.push({ divider: true });
              }
              if (typeof data.results !== 'undefined') {
                data.results.forEach(function (result) {
                  values.push({ data: { label: result.hue_name, icon: SEARCH_TYPE_ICONS[result.type],  description: result.hue_description }, value: beforePartial + result.originalName });
                });
              }

              if (values.length > 0 && values[values.length - 1].divider) {
                values.pop();
              }
              if (values.length === 0) {
                values.push({ noMatch: true });
              }
              callback(values);
            },
            silenceErrors: true,
            errorCallback: function () {
              callback([]);
            }
          });
        };
      }

      TopNavViewModel.prototype.performSearch = function () {
      };


      ko.applyBindings(new TopNavViewModel(), $('.top-nav')[0]);
    })();

    window.hueDebug = {
      viewModel: function () {
        return window.hueDebug.onePageViewModel();
      },
      onePageViewModel: function () {
        return ko.dataFor($('.page-content')[0]);
      },
      sidePanelViewModel: function () {
        return ko.dataFor($('.left-panel')[0]);
      },
      topNavViewModel: function () {
        return ko.dataFor($('.top-nav')[0]);
      }
    };
  });

  $(".hamburger").click(function () {
    $(this).toggleClass("is-active");
    $(".left-nav").toggleClass("left-nav-visible");
  });

  moment.locale(window.navigator.userLanguage || window.navigator.language);
  localeFormat = function (time) {
    var mTime = time;
    if (typeof ko !== 'undefined' && ko.isObservable(time)) {
      mTime = time();
    }
    try {
      mTime = new Date(mTime);
      if (moment(mTime).isValid()) {
        return moment.utc(mTime).format("L LT");
      }
    }
    catch (e) {
      return mTime;
    }
    return mTime;
  };

  // Add CSRF Token to all XHR Requests
  var xrhsend = XMLHttpRequest.prototype.send;
  XMLHttpRequest.prototype.send = function (data) {
    % if request and request.COOKIES and request.COOKIES.get('csrftoken'):
      this.setRequestHeader('X-CSRFToken', "${ request.COOKIES.get('csrftoken') }");
    % else:
      this.setRequestHeader('X-CSRFToken', "");
    % endif

    return xrhsend.apply(this, arguments);
  };

  // Set global assistHelper TTL
  $.totalStorage('hue.cacheable.ttl', ${conf.CUSTOM.CACHEABLE_TTL.get()});

  $(document).ready(function () {
##       // forces IE's ajax calls not to cache
##       if ($.browser.msie) {
##         $.ajaxSetup({ cache: false });
##       }

    // prevents framebusting and clickjacking
    if (self == top) {
      $("body").css({
        'display': 'block',
        'visibility': 'visible'
      });
    } else {
      top.location = self.location;
    }

    %if conf.AUTH.IDLE_SESSION_TIMEOUT.get() > -1 and not skip_idle_timeout:
      var idleTimer;

      function resetIdleTimer() {
        clearTimeout(idleTimer);
        idleTimer = setTimeout(function () {
          // Check if logged out
          $.get('/desktop/debug/is_idle');
        }, ${conf.AUTH.IDLE_SESSION_TIMEOUT.get()} * 1000 + 1000
        );
      }

      $(document).on('mousemove', resetIdleTimer);
      $(document).on('keydown', resetIdleTimer);
      $(document).on('click', resetIdleTimer);
      resetIdleTimer();
    %endif

    % if 'jobbrowser' in apps:
      var JB_CHECK_INTERVAL_IN_MILLIS = 30000;
      var checkJobBrowserStatusIdx = window.setTimeout(checkJobBrowserStatus, 10);

      function checkJobBrowserStatus(){
        $.post("/jobbrowser/jobs/", {
            "format": "json",
            "state": "running",
            "user": "${user.username}"
          },
          function(data) {
            if (data != null && data.jobs != null) {
              huePubSub.publish('jobbrowser.data', data.jobs);
              if (data.jobs.length > 0){
                $("#jobBrowserCount").removeClass("hide").text(data.jobs.length);
              }
              else {
                $("#jobBrowserCount").addClass("hide");
              }
            }
          checkJobBrowserStatusIdx = window.setTimeout(checkJobBrowserStatus, JB_CHECK_INTERVAL_IN_MILLIS);
        }).fail(function () {
          window.clearTimeout(checkJobBrowserStatusIdx);
        });
      }
      huePubSub.subscribe('check.job.browser', checkJobBrowserStatus);
    % endif
  });

</script>

<script type="text/javascript">

  $(document).ready(function () {
    // global catch for ajax calls after the user has logged out
    var isLoginRequired = false;
    $(document).ajaxComplete(function (event, xhr, settings) {
      if (xhr.responseText === '/* login required */' && !isLoginRequired) {
        isLoginRequired = true;
        $('body').children(':not(#login-modal)').addClass('blurred');
        if ($('#login-modal').length > 0) {
          $('#login-modal').modal('show');
          window.setTimeout(function () {
            $('.jHueNotify').remove();
          }, 200);
        }
        else {
          location.reload();
        }
      }
    });

    $('#login-modal').on('hidden', function () {
      isLoginRequired = false;
      $('.blurred').removeClass('blurred');
    });

    huePubSub.subscribe('hue.login.result', function (response) {
      if (response.auth) {
        $('#login-modal').modal('hide');
        $.jHueNotify.info('${ _('You have signed in successfully!') }');
        $('#login-modal .login-error').addClass('hide');
      } else {
        $('#login-modal .login-error').removeClass('hide');
      }
    });
  });

  $(".modal").on("shown", function () {
    // safe ux enhancement: focus on the first editable input
    $(".modal:visible").find("input:not(.disable-autofocus):visible:first").focus();
  });

    %if collect_usage:
      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', 'UA-40351920-1']);

      // We collect only 2 path levels: not hostname, no IDs, no anchors...
      var _pathName = location.pathname;
      var _splits = _pathName.substr(1).split("/");
      _pathName = _splits[0] + (_splits.length > 1 && $.trim(_splits[1]) != "" ? "/" + _splits[1] : "");

      _gaq.push(['_trackPageview', '/remote/${ version }/' + _pathName]);

      (function () {
        var ga = document.createElement('script');
        ga.type = 'text/javascript';
        ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0];
        s.parentNode.insertBefore(ga, s);
      })();

      function trackOnGA(path) {
        if (typeof _gaq != "undefined" && _gaq != null) {
          _gaq.push(['_trackPageview', '/remote/${ version }/' + path]);
        }
      }
    %endif
</script>
</body>
</html>