import {
  List,
  Datagrid,
  TextField,
  DateField,
  NumberField,
  BooleanField,
  ReferenceField,
  Show,
  SimpleShowLayout,
  Edit,
  SimpleForm,
  TextInput,
  DateInput,
  NumberInput,
  BooleanInput,
  ReferenceInput,
  SelectInput,
  required,
} from "react-admin";

const DeploymentFilter = [
    <TextInput label="Search" source="id" alwaysOn />,
    <ReferenceInput source="ring" reference="ring" />,
    <TextInput label="Colony" source="colony" />,
    <TextInput label="Sex" source="sex" />,
    <DateInput label="Date" source="date" />,
    <TextInput label="Data Responsible" source="data_responsible" />,
];

export const DeploymentList = () => (
  <List perPage={25} filters={DeploymentFilter}>
    <Datagrid rowClick="show">
      <TextField source="id" />
      <ReferenceField source="ring" reference="ring" />
      <DateField source="date" />
      <TextField source="colony" />
      <TextField source="sex" />
      <TextField source="age" />
      <TextField source="breeding_stage_deployment" />
      <TextField source="data_responsible" />
    </Datagrid>
  </List>
);

export const DeploymentShow = () => (
  <Show>
    <SimpleShowLayout>
      <TextField source="id" />
      <ReferenceField source="ring" reference="ring" />
      <DateField source="date" />
      <ReferenceField source="colony" reference="colony" link="show">
        <TextField source="name" />
      </ReferenceField>
      <NumberField source="total_logger_mass_all_loggers_g" />
      <TextField source="age" />
      <TextField source="sex" />
      <TextField source="sexing_method" />
      <NumberField source="mass_deployment_g" />
      <NumberField source="mass_retrieval_g" />
      <NumberField source="scull_mm" />
      <NumberField source="tarsus_mm" />
      <NumberField source="wing_mm" />
      <NumberField source="culmen_mm" />
      <NumberField source="gonys_mm" />
      <TextField source="breeding_stage_deployment" />
      <TextField source="eggs_deployment" />
      <TextField source="chicks_deployment" />
      <BooleanField source="chicks_deployment_extra" />
      <BooleanField source="eggs_deployment_extra" />
      <TextField source="breeding_stage_retrieval" />
      <TextField source="eggs_retrieval" />
      <TextField source="chicks_retrieval" />
      <BooleanField source="chicks_retrieval_extra" />
      <BooleanField source="eggs_retrieval_extra" />
      <TextField source="further_chick_measures_available" />
      <BooleanField source="more_information_on_breeding_success_available" />
      <BooleanField source="sample_blood" />
      <BooleanField source="sample_feather" />
      <BooleanField source="sample_other" />
      <TextField source="sample_notes" />
      <TextField source="comment" />
      <TextField source="other" />
      <TextField source="funding_source" />
      <TextField source="data_responsible" />
    </SimpleShowLayout>
  </Show>
);

export const DeploymentEdit = () => (
  <Edit>
    <SimpleForm>
      <TextInput source="id" disabled />
      <ReferenceInput source="ring" reference="ring">
        <SelectInput validate={required()} />
      </ReferenceInput>
      <DateInput source="date" validate={required()} />
      <ReferenceInput source="colony" reference="colony">
        <SelectInput />
      </ReferenceInput>
      <NumberInput source="total_logger_mass_all_loggers_g" />
      <TextInput source="age" />
      <TextInput source="sex" />
      <TextInput source="sexing_method" />
      <NumberInput source="mass_deployment_g" />
      <NumberInput source="mass_retrieval_g" />
      <NumberInput source="scull_mm" />
      <NumberInput source="tarsus_mm" />
      <NumberInput source="wing_mm" />
      <NumberInput source="culmen_mm" />
      <NumberInput source="gonys_mm" />
      <TextInput source="breeding_stage_deployment" />
      <TextInput source="eggs_deployment" />
      <TextInput source="chicks_deployment" />
      <BooleanInput source="chicks_deployment_extra" />
      <BooleanInput source="eggs_deployment_extra" />
      <TextInput source="breeding_stage_retrieval" />
      <TextInput source="eggs_retrieval" />
      <TextInput source="chicks_retrieval" />
      <BooleanInput source="chicks_retrieval_extra" />
      <BooleanInput source="eggs_retrieval_extra" />
      <TextInput source="further_chick_measures_available" />
      <BooleanInput source="more_information_on_breeding_success_available" />
      <BooleanInput source="sample_blood" />
      <BooleanInput source="sample_feather" />
      <BooleanInput source="sample_other" />
      <TextInput source="sample_notes" multiline />
      <TextInput source="comment" multiline />
      <TextInput source="other" multiline />
      <TextInput source="funding_source" />
      <TextInput source="data_responsible" />
    </SimpleForm>
  </Edit>
);
