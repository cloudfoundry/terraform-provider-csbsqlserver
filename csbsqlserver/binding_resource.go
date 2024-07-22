package csbsqlserver

import (
	"context"
	"fmt"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"

	"github.com/cloudfoundry/terraform-provider-csbsqlserver/connector"
)

const (
	bindingUsername = "username"
	bindingPassword = "password"
	bindingRoles    = "roles"
	bindingDatabase = "database"
)

func BindingResource() *schema.Resource {
	return &schema.Resource{
		Description: "A MS-SQL Server binding for the CSB brokerpak",
		Schema: map[string]*schema.Schema{
			bindingUsername: {
				Type:     schema.TypeString,
				Required: true,
			},
			bindingPassword: {
				Type:     schema.TypeString,
				Required: true,
			},
			bindingRoles: {
				Type:     schema.TypeList,
				Optional: true,
				Elem: &schema.Schema{
					Type:     schema.TypeString,
					MaxItems: 100,
					MinItems: 0,
				},
			},
			bindingDatabase: {
				Type:     schema.TypeString,
				Optional: true,
				Default:  "",
			},
		},
		CreateContext: create,
		ReadContext:   read,
		UpdateContext: update,
		DeleteContext: delete,
		UseJSONNumber: true,
	}
}

func create(ctx context.Context, d *schema.ResourceData, m any) diag.Diagnostics {
	var (
		username string
		password string
		roles    []string
	)
	for _, f := range []func() diag.Diagnostics{
		func() (diags diag.Diagnostics) {
			username, diags = getIdentifier(d, "username")
			return
		},
		func() (diags diag.Diagnostics) {
			password, diags = getPassword(d, "password")
			return
		},
		func() (diags diag.Diagnostics) {
			roles, diags = getRoles(d, "roles")
			return
		},
		func() diag.Diagnostics {
			conn := m.(*connector.Connector)
			database := d.Get(bindingDatabase).(string)
			if database != "" {
				conn.WithDatabase(database)
			}
			if err := conn.CreateBinding(ctx, username, password, roles); err != nil {
				return diag.FromErr(err)
			}

			d.SetId(username)
			return nil
		},
	} {
		if d := f(); d != nil {
			return d
		}
	}

	return nil
}

func read(ctx context.Context, d *schema.ResourceData, m any) diag.Diagnostics {
	username, diags := getIdentifier(d, "username")
	if diags != nil {
		return diags
	}

	conn := m.(*connector.Connector)

	database := d.Get(bindingDatabase).(string)
	if database != "" {
		conn.WithDatabase(database)
	}

	ok, err := conn.ReadBinding(ctx, username)
	if err != nil {
		return diag.FromErr(err)
	}

	switch ok {
	case true:
		d.SetId(username)
	default:
		d.SetId("")
	}

	return nil
}

func update(_ context.Context, _ *schema.ResourceData, _ any) diag.Diagnostics {
	return diag.FromErr(fmt.Errorf("update lifecycle not implemented"))
}

func delete(ctx context.Context, d *schema.ResourceData, m any) diag.Diagnostics {
	username, diags := getIdentifier(d, "username")
	if diags != nil {
		return diags
	}

	conn := m.(*connector.Connector)
	database := d.Get(bindingDatabase).(string)
	if database != "" {
		conn.WithDatabase(database)
	}

	if err := conn.DeleteBinding(ctx, username); err != nil {
		return diag.FromErr(err)
	}

	return nil
}
