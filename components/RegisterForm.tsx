'use client'

import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'
import * as z from 'zod'
import { useRouter } from 'next/navigation'
import { createClient } from '@/utils/supabase/client'

import { Button } from './ui/button'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Textarea } from './ui/textarea'
import { Input } from '@/components/ui/input'

const signUpFormSchema = z
  .object({
    first_name: z
      .string()
      .min(1, { message: 'Please input your name' })
      .max(50, {
        message: "Your first name shouldn't be longer than 50 characters",
      }),
    last_name: z
      .string()
      .min(1, { message: 'Please input your last name' })
      .max(50, {
        message: "Your last name shouldn' be longer than 50 characters",
      }),
    ci: z.string().min(1, { message: 'Please input your C.I number' }).max(10, {
      message: "Your C.I number shouldn't be longer than 10 digits",
    }),
    address: z
      .string()
      .min(1, { message: 'Please input an address' })
      .max(100, {
        message: "Your address shouldn't be longer than 100 characters",
      }),
    email: z.string().email({ message: 'Please enter a valid email' }),
    password: z.string().min(8, {
      message: 'Your password should be at least 8 characters long',
    }),
    confirmPassword: z.string().min(8, {
      message: 'Your password should be at least 8 characters long',
    }),
  })
  .refine((data) => data.password === data.confirmPassword, {
    path: ['confirmPassword'],
    message: 'Passwords does not match',
  })

export default function RegisterForm() {
  const router = useRouter()
  const supabase = createClient()

  const form = useForm<z.infer<typeof signUpFormSchema>>({
    resolver: zodResolver(signUpFormSchema),
    defaultValues: {
      first_name: '',
      last_name: '',
      ci: '',
      address: '',
      email: '',
      password: '',
      confirmPassword: '',
    },
  })

  const signUp = async (values: z.infer<typeof signUpFormSchema>) => {
    const email = values.email
    const password = values.password
    const firstName = values.first_name
    const lastName = values.last_name
    const ci = values.ci
    const address = values.address

    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          first_name: firstName,
          last_name: lastName,
          ci,
          address,
        },
        emailRedirectTo: `${process.env.HOST}/auth/callback`,
      },
    })

    if (error) {
      router.push('/login?message=Could not authenticate the user')
    } else {
      router.push('/login?message=Check email to continue sign in process')
    }
  }

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(signUp)}
        className="grid grid-cols-2 w-full justify-center gap-2 text-foreground items-end"
      >
        <FormField
          control={form.control}
          name="first_name"
          render={({ field }) => (
            <FormItem className="col-span-2 sm:col-span-1">
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input placeholder="First name" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="last_name"
          render={({ field }) => (
            <FormItem className="col-span-2 sm:col-span-1">
              <FormControl>
                <Input placeholder="Last name" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="ci"
          render={({ field }) => (
            <FormItem className="col-span-2">
              <FormLabel>C.I Number</FormLabel>
              <FormControl>
                <Input placeholder="ex. 00000000" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="address"
          render={({ field }) => (
            <FormItem className="col-span-2">
              <FormLabel>Address</FormLabel>
              <FormControl>
                <Textarea
                  placeholder="Full Street, City, State, Postcode"
                  className="resize-none"
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem className="col-span-2">
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input placeholder="you@example.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem className="col-span-2">
              <FormLabel>Password</FormLabel>
              <FormControl>
                <Input placeholder="••••••••" type="password" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="confirmPassword"
          render={({ field }) => (
            <FormItem className="col-span-2">
              <FormLabel>Confirm password</FormLabel>
              <FormControl>
                <Input placeholder="••••••••" type="password" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit" className="col-span-2 mb-2 mt-4">
          Sign Up
        </Button>
      </form>
    </Form>
  )
}
