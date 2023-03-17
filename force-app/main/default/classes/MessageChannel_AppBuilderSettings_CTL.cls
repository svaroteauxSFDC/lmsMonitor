global class MessageChannel_AppBuilderSettings_CTL extends VisualEditor.DynamicPickList {
    global override VisualEditor.DataRow getDefaultValue() {
        return new VisualEditor.DataRow('---','N/A');
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        map<string, LMS_Monitor_Setting__mdt> lmsMonitorSettings = LMS_Monitor_Setting__mdt.getAll();
        VisualEditor.DynamicPickListRows  settingValues = new VisualEditor.DynamicPickListRows();
        settingValues.addRow(new VisualEditor.DataRow('---','N/A'));

        for (string key: lmsMonitorSettings.keySet()) {
            settingValues.addRow(new VisualEditor.DataRow(lmsMonitorSettings.get(key).MasterLabel, key));
        }

        return settingValues;
    }
}